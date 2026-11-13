#!/usr/bin/env python3
"""A/B regression report: compare two Jekyll builds of this site, page by page.

    python3 scripts/ab_compare.py A_DIR B_DIR OUT_DIR [--shots] [--only PATH ...]

A is the baseline build (e.g. main), B the candidate (e.g. a redesign branch).
Both should be built the same way, ideally `JEKYLL_ENV=production bundle exec
jekyll build -d <dir>`. Writes OUT_DIR/report.html and exits non-zero if any
check FAILs. Standard library only; screenshots (--shots) need Google Chrome.

Checks per page:
  * page exists in both builds
  * SEO head: <title>, meta description, canonical, robots, og:*/twitter:*,
    and the JSON-LD blocks
  * main-content text: similarity ratio + the words that disappeared
    (site header/nav/footer, scripts and styles are stripped first)
  * content links/images (href/src) that disappeared
  * element ids (in-page anchors) that disappeared
Site-wide: every internal href/src in B resolves to a file in B.
"""
import argparse
import difflib
import html
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import threading
import time
from collections import Counter
from functools import partial
from html.parser import HTMLParser
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, unquote

SITE_HOSTS = {"shivaram.net", "www.shivaram.net", "127.0.0.1", "localhost"}
SKIP_PREFIXES = ("plain/",)  # design prototypes, not part of the site
# Elements whose contents are site chrome rather than page content.
CHROME_TAGS = {"script", "style", "noscript", "template", "nav", "footer", "header", "head"}
CHROME_IDS = {"footer", "nav-search", "post-toc", "toc-fab", "toc-sheet", "reading-progress",
              "post-lightbox", "photo-lightbox", "search-panel"}
CHROME_CLASSES = {"navbar", "masthead", "site-footer", "proto-banner", "toc-inline"}
VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "source", "track", "wbr"}
CHROME_BINARY = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# Refs that a redesign may drop on purpose (framework JS/CSS, icon fonts); reported as INFO.
EXPECTED_GONE = re.compile(r"/assets/javascript/bootstrap/|/assets/main\.css|fonts\.googleapis|phosphor-icons|fontawesome|academicons|calendly\.com/assets")
# ISO timestamps: compare the date only, so two builds of the same day agree
# (jekyll-seo-tag stamps undated notes with the build time).
TIMESTAMP = re.compile(r"(\d{4}-\d{2}-\d{2})T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)?")


class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.title, self.meta, self.canonical, self.jsonld = "", {}, "", []
        self.text, self.links, self.ids, self.all_refs = [], set(), set(), set()
        self._stack, self._skip, self._in_title, self._in_jsonld = [], 0, False, False
        self._buf = []

    def _is_chrome(self, tag, a):
        if tag in CHROME_TAGS:
            return True
        if a.get("id") in CHROME_IDS:
            return True
        return bool(CHROME_CLASSES & set((a.get("class") or "").split()))

    def handle_starttag(self, tag, attrs):
        a = {k: (v or "") for k, v in attrs}
        if tag == "title":
            self._in_title = True
        if tag == "meta":
            key = a.get("name") or a.get("property")
            if key:
                self.meta[key.lower()] = a.get("content", "").strip()
        if tag == "link" and "canonical" in a.get("rel", ""):
            self.canonical = a.get("href", "")
        if tag == "script" and a.get("type") == "application/ld+json":
            self._in_jsonld, self._buf = True, []
        if a.get("id"):
            self.ids.add(a["id"])
        for attr in ("href", "src", "poster"):
            if a.get(attr):
                self.all_refs.add(a[attr])
                if not self._skip:
                    self.links.add(a[attr])
        if tag in VOID:
            return
        chrome = self._is_chrome(tag, a)
        self._stack.append(chrome)
        if chrome:
            self._skip += 1

    def handle_endtag(self, tag):
        if tag == "title":
            self._in_title = False
        if tag == "script" and self._in_jsonld:
            self._in_jsonld = False
            self.jsonld.append("".join(self._buf))
        if tag in VOID or not self._stack:
            return
        if self._stack.pop():
            self._skip -= 1

    def handle_data(self, data):
        if self._in_title:
            self.title += data
        if self._in_jsonld:
            self._buf.append(data)
        elif not self._skip:
            self.text.append(data)


def parse(path):
    p = Page()
    with open(path, encoding="utf-8", errors="replace") as fh:
        p.feed(fh.read())
    p.title = " ".join(p.title.split())
    p.words = re.findall(r"[\w’'.-]+", " ".join(p.text).lower())
    p.words = [w.strip(".-'’") for w in p.words if w.strip(".-'’")]
    return p


def html_pages(root):
    out = []
    for dirpath, _, files in os.walk(root):
        for f in files:
            if f.endswith(".html"):
                rel = os.path.relpath(os.path.join(dirpath, f), root)
                if not rel.startswith(SKIP_PREFIXES):
                    out.append(rel)
    return sorted(out)


def norm_jsonld(blocks):
    out = []
    for b in blocks:
        b = TIMESTAMP.sub(r"\1", b)
        try:
            out.append(json.dumps(json.loads(b), sort_keys=True))
        except ValueError:
            out.append(" ".join(b.split()))
    return sorted(out)


def internal_target(ref, page_rel):
    """Map an href/src to a path inside the build, or None if external."""
    if ref.startswith(("mailto:", "tel:", "javascript:", "data:", "#")):
        return None
    u = urlparse(ref)
    if u.scheme in ("http", "https") and u.hostname not in SITE_HOSTS:
        return None
    if u.scheme and u.scheme not in ("http", "https"):
        return None
    path = unquote(u.path)
    if not path:
        return None
    if not path.startswith("/"):
        path = "/" + os.path.normpath(os.path.join(os.path.dirname(page_rel), path)).lstrip("./")
    return path


def resolves(root, path):
    p = os.path.join(root, path.lstrip("/"))
    return (os.path.isfile(p) or os.path.isfile(os.path.join(p, "index.html"))
            or os.path.isfile(p + ".html"))


def norm_ref(ref):
    ref = re.sub(r"[?&]v=\d+", "", ref)
    ref = re.sub(r"^https?://(www\.)?shivaram\.net", "", ref)
    return ref[:-1] if len(ref) > 1 and ref.endswith("/") else ref  # /about == /about/


# ---------------------------------------------------------------- screenshots
def free_port():
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def serve(root):
    port = free_port()
    handler = partial(SimpleHTTPRequestHandler, directory=root)
    handler.log_message = lambda *a, **k: None
    srv = ThreadingHTTPServer(("127.0.0.1", port), handler)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    return srv, port


def url_for(port, rel):
    path = "/" + rel
    if path.endswith("/index.html"):
        path = path[: -len("index.html")]
    return f"http://127.0.0.1:{port}{path}"


def chrome_shot(url, out, width, height):
    subprocess.run([CHROME_BINARY, "--headless=new", "--hide-scrollbars", "--disable-gpu",
                    "--blink-settings=preferredColorScheme=1",
                    f"--window-size={width},{height}", "--virtual-time-budget=4000",
                    f"--screenshot={out}", url],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=90)


def phone_shot(url, out, tmpdir):
    """Headless Chrome won't go below 500px wide, so frame the page at 390px."""
    frame = os.path.join(tmpdir, "phone-frame.html")
    with open(frame, "w") as fh:
        fh.write(f'<body style="margin:0"><iframe src="{html.escape(url)}" width="390" '
                 f'height="1400" style="border:0"></iframe></body>')
    chrome_shot("file://" + frame, out, 390, 1400)


# --------------------------------------------------------------------- report
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("a"), ap.add_argument("b"), ap.add_argument("out")
    ap.add_argument("--shots", action="store_true", help="add desktop + phone screenshots")
    ap.add_argument("--only", nargs="*", help="limit to these page paths (e.g. index.html about/index.html)")
    args = ap.parse_args()

    a_pages, b_pages = html_pages(args.a), html_pages(args.b)
    pages = sorted(set(a_pages) | set(b_pages))
    if args.only:
        pages = [p for p in pages if p in args.only]
    os.makedirs(args.out, exist_ok=True)
    shots_dir = os.path.join(args.out, "shots")
    if args.shots:
        os.makedirs(shots_dir, exist_ok=True)
        srv_a, port_a = serve(args.a)
        srv_b, port_b = serve(args.b)

    rows, fails, warns = [], 0, 0
    for rel in pages:
        issues = []  # (level, message)
        in_a, in_b = rel in a_pages, rel in b_pages
        if not in_b:
            issues.append(("FAIL", "page missing in B"))
        if not in_a:
            issues.append(("INFO", "new page in B"))
        sim, lost_words, lost_links, lost_ids = None, [], [], []
        if in_a and in_b:
            A, B = parse(os.path.join(args.a, rel)), parse(os.path.join(args.b, rel))
            if A.title != B.title:
                issues.append(("WARN", f"title: {A.title!r} → {B.title!r}"))
            for key in sorted(set(A.meta) | set(B.meta)):
                if key in ("viewport", "generator", "theme-color") or key.startswith(("og:image:", "twitter:image:")):
                    continue
                if TIMESTAMP.sub(r"\1", A.meta.get(key) or "") == TIMESTAMP.sub(r"\1", B.meta.get(key) or ""):
                    continue
                if A.meta.get(key) != B.meta.get(key):
                    lvl = "FAIL" if key in ("description", "robots", "og:title", "og:url", "og:description") else "WARN"
                    issues.append((lvl, f"meta {key}: {A.meta.get(key)!r} → {B.meta.get(key)!r}"))
            if A.canonical != B.canonical:
                issues.append(("FAIL", f"canonical: {A.canonical!r} → {B.canonical!r}"))
            if norm_jsonld(A.jsonld) != norm_jsonld(B.jsonld):
                issues.append(("FAIL", f"JSON-LD blocks differ ({len(A.jsonld)} → {len(B.jsonld)})"))
            sim = difflib.SequenceMatcher(None, A.words, B.words, autojunk=False).ratio() if A.words or B.words else 1.0
            lost = Counter(A.words) - Counter(B.words)
            lost_words = [w for w, _ in lost.most_common(40) if len(w) > 2]
            if sum(lost.values()) > max(8, 0.03 * len(A.words)):
                issues.append(("WARN", f"{sum(lost.values())} words of content gone"))
            a_links = {norm_ref(x) for x in A.links}
            b_links = {norm_ref(x) for x in B.all_refs}
            gone = sorted(x for x in a_links - b_links if not x.startswith("#"))
            expected = [x for x in gone if EXPECTED_GONE.search(x)]
            lost_links = [x for x in gone if x not in expected]
            if expected:
                issues.append(("INFO", "removed on purpose: " + ", ".join(expected)))
            if lost_links:
                issues.append(("WARN", f"{len(lost_links)} content link(s)/image(s) gone"))
            lost_ids = sorted(A.ids - B.ids)
        if in_b:
            def broken_in(root):
                P = parse(os.path.join(root, rel))
                return {norm_ref(r) for r in P.all_refs
                        if (t := internal_target(r, rel)) and not resolves(root, t)}
            broken = broken_in(args.b)
            already = broken_in(args.a) if in_a else set()
            if broken - already:
                issues.append(("FAIL", "broken internal refs: " + ", ".join(sorted(broken - already)[:8])))
            if broken & already:
                issues.append(("INFO", "already broken in A: " + ", ".join(sorted(broken & already)[:8])))
        if args.shots:
            slug = re.sub(r"[^\w]+", "_", rel)
            for side, port, ok in (("A", port_a if args.shots else 0, in_a), ("B", port_b if args.shots else 0, in_b)):
                if not ok:
                    continue
                u = url_for(port, rel)
                chrome_shot(u, os.path.join(shots_dir, f"{slug}-{side}-desk.png"), 1280, 1600)
                phone_shot(u, os.path.join(shots_dir, f"{slug}-{side}-phone.png"), args.out)
        fails += any(l == "FAIL" for l, _ in issues)
        warns += any(l == "WARN" for l, _ in issues)
        rows.append(dict(rel=rel, issues=issues, sim=sim, lost_words=lost_words,
                         lost_links=lost_links, lost_ids=lost_ids))

    # site-level artefacts that aren't HTML pages
    extra = []
    for f in ("feed.xml", "sitemap.xml", "robots.txt", "search.json", "CNAME", "favicon.ico"):
        if os.path.exists(os.path.join(args.a, f)) and not os.path.exists(os.path.join(args.b, f)):
            extra.append(f"FAIL: {f} missing in B")
            fails += 1

    write_report(args, rows, extra, fails, warns)
    if args.shots:
        srv_a.shutdown(), srv_b.shutdown()
    print(f"{len(rows)} pages · {fails} with FAIL · {warns} with WARN → {os.path.join(args.out, 'report.html')}")
    for r in rows:
        for lvl, msg in r["issues"]:
            if lvl in ("FAIL", "WARN"):
                print(f"  {lvl} {r['rel']}: {msg}")
    for e in extra:
        print("  " + e)
    sys.exit(1 if fails else 0)


def write_report(args, rows, extra, fails, warns):
    e = html.escape
    out = ['<!doctype html><meta charset="utf-8"><title>A/B report</title><style>'
           'body{font:14px/1.4 -apple-system,Helvetica,Arial,sans-serif;margin:20px;color:#111}'
           'table{border-collapse:collapse;width:100%}td,th{border:1px solid #ccc;padding:4px 8px;vertical-align:top;text-align:left}'
           '.FAIL{color:#b00;font-weight:bold}.WARN{color:#a60}.INFO{color:#555}.ok{color:#070}'
           '.shots{display:grid;grid-template-columns:1fr 1fr 200px 200px;gap:8px;margin:6px 0 24px}'
           '.shots img{width:100%;border:1px solid #999}.shots figure{margin:0}figcaption{font-size:12px;color:#555}'
           'details{margin:2px 0}code{font-size:12px}</style>',
           f'<h1>A/B report</h1><p>A = <code>{e(args.a)}</code><br>B = <code>{e(args.b)}</code><br>'
           f'{len(rows)} pages · <span class="FAIL">{fails} FAIL</span> · <span class="WARN">{warns} WARN</span></p>']
    for x in extra:
        out.append(f'<p class="FAIL">{e(x)}</p>')
    out.append('<table><tr><th>page</th><th>text kept</th><th>issues</th></tr>')
    for r in rows:
        sim = "—" if r["sim"] is None else f'{r["sim"]:.0%}'
        iss = "".join(f'<div class="{l}">{l}: {e(m)}</div>' for l, m in r["issues"]) or '<span class="ok">ok</span>'
        det = ""
        if r["lost_words"]:
            det += f'<details><summary>words gone</summary><code>{e(" ".join(r["lost_words"]))}</code></details>'
        if r["lost_links"]:
            det += '<details><summary>links/images gone</summary>' + "<br>".join(f"<code>{e(x)}</code>" for x in r["lost_links"]) + "</details>"
        if r["lost_ids"]:
            det += f'<details><summary>anchors gone</summary><code>{e(" ".join(r["lost_ids"]))}</code></details>'
        out.append(f'<tr><td><a href="#{e(r["rel"])}">{e(r["rel"])}</a></td><td>{sim}</td><td>{iss}{det}</td></tr>')
    out.append("</table>")
    if args.shots:
        out.append("<h2>Screenshots (A old | B new | A phone | B phone)</h2>")
        for r in rows:
            slug = re.sub(r"[^\w]+", "_", r["rel"])
            out.append(f'<h3 id="{e(r["rel"])}">{e(r["rel"])}</h3><div class="shots">')
            for name in ("A-desk", "B-desk", "A-phone", "B-phone"):
                src = f"shots/{slug}-{name}.png"
                if os.path.exists(os.path.join(args.out, src)):
                    out.append(f'<figure><a href="{src}"><img src="{src}" loading="lazy"></a><figcaption>{name}</figcaption></figure>')
                else:
                    out.append(f"<figure><figcaption>{name}: n/a</figcaption></figure>")
            out.append("</div>")
    with open(os.path.join(args.out, "report.html"), "w") as fh:
        fh.write("\n".join(out))


if __name__ == "__main__":
    main()
