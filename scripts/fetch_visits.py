#!/usr/bin/env python3
"""
Fetch per-country HUMAN visitor counts from Cloudflare Web Analytics (RUM) and
write them to assets/visits.json for the home-page world map.

RUM = a JS beacon that only fires in real browsers, so bots, crawlers and asset
requests are excluded (unlike raw zone "requests"). Page-load events ≈ human views.

Environment (set as GitHub Actions secrets):
  CF_API_TOKEN   — token with "Account Analytics: Read"
  CF_ACCOUNT_ID  — Cloudflare account id (923e914b361aac00ff4b58c2f547a0ff)
  CF_SITE_TAG    — Web Analytics site tag (Dashboard → Analytics → Web Analytics → site → "Site Tag")
  CF_DAYS        — optional lookback window in days (default 30)
"""
import os, sys, json, datetime, urllib.request

TOKEN   = os.environ["CF_API_TOKEN"]
ACCOUNT = os.environ["CF_ACCOUNT_ID"]
SITE    = os.environ["CF_SITE_TAG"]
DAYS    = int(os.environ.get("CF_DAYS", "30"))
OUT     = "assets/visits.json"

until = datetime.datetime.utcnow().replace(microsecond=0)
since = until - datetime.timedelta(days=DAYS)

QUERY = """
query($account:String!, $site:String!, $since:Time!, $until:Time!){
  viewer{
    accounts(filter:{accountTag:$account}){
      rumPageloadEventsAdaptiveGroups(
        limit: 300,
        filter: { datetime_geq:$since, datetime_leq:$until, siteTag:$site },
        orderBy: [count_DESC]
      ){
        count
        dimensions { countryName }
      }
    }
  }
}
"""

def gql():
    body = json.dumps({
        "query": QUERY,
        "variables": {
            "account": ACCOUNT, "site": SITE,
            "since": since.isoformat() + "Z", "until": until.isoformat() + "Z",
        },
    }).encode()
    req = urllib.request.Request(
        "https://api.cloudflare.com/client/v4/graphql",
        data=body,
        headers={"Authorization": "Bearer " + TOKEN, "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)

def main():
    resp = gql()
    if resp.get("errors"):
        print("GraphQL errors:", json.dumps(resp["errors"], indent=2))
        sys.exit(1)
    groups = resp["data"]["viewer"]["accounts"][0]["rumPageloadEventsAdaptiveGroups"]
    counts = {}
    for g in groups:
        cc = (g["dimensions"].get("countryName") or "").upper()
        if cc and cc not in ("", "XX", "T1"):       # T1 = Tor / unknown
            counts[cc] = counts.get(cc, 0) + g["count"]
    counts = dict(sorted(counts.items(), key=lambda kv: kv[1], reverse=True))
    out = {
        "updated": until.date().isoformat(),
        "source": "cloudflare-rum",
        "days": DAYS,
        "counts": counts,
    }
    os.makedirs("assets", exist_ok=True)
    with open(OUT, "w") as f:
        json.dump(out, f, indent=2)
    print("wrote %s — %d countries, %d human page views" % (OUT, len(counts), sum(counts.values())))

if __name__ == "__main__":
    main()
