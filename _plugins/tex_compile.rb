# TeX / LaTeX compilation for Jekyll — compile research-grade LaTeX and render
# it as real page content (ar5iv-style), with the compiled PDF kept for download.
#
#   {% tex_cell label=my-paper %}
#   \title{A short note}
#   \maketitle
#   \section{Intro}
#   ...
#   {% endtex_cell %}
#
#   {% tex_file "/assets/papers/example-paper.tex" %}
#
# What happens at build time:
#   1. pandoc converts the LaTeX to HTML — the paper becomes selectable page
#      content, math stays as \(...\) TeX so the site's MathJax renders it,
#      tables/citations become live HTML.
#   2. pdfLaTeX compiles the same source to a PDF, staged next to the HTML so
#      it can be downloaded. Compile failures degrade gracefully (HTML still
#      renders, the PDF failure surfaces as a warning + log).
#
# Everything is cached in .jekyll-cache/tex/<sha>/ and only rebuilt when the
# source changes. The PDF is copied into _site after the build (Jekyll's
# Cleaner removes unknown files between render and write).
#
# Requires: pandoc, pdflatex (TeX Live), pdfinfo (poppler). Override the
# binaries with the PANDOC / PDFLATEX / PDFINFO environment variables.
require "cgi"
require "digest"
require "fileutils"
require "open3"

module Jekyll
  module TexEngine
    PANDOC   = ENV.fetch("PANDOC", "pandoc")
    PDFLATEX = ENV.fetch("PDFLATEX", "pdflatex")
    PDFINFO  = ENV.fetch("PDFINFO", "pdfinfo")
    # Bump when post-processing / pandoc flags change so stale caches rebuild.
    CACHE_VERSION = "2"

    DEFAULT_PREAMBLE = <<~'TEX'
      \documentclass[11pt]{article}
      \usepackage[margin=1in]{geometry}
      \usepackage[utf8]{inputenc}
      \usepackage[T1]{fontenc}
      \usepackage{amsmath,amssymb}
      \usepackage{microtype}
      \usepackage{graphicx}
      \usepackage{booktabs}
      \usepackage{enumitem}
      \usepackage[colorlinks=true,urlcolor=blue,linkcolor=black,citecolor=blue]{hyperref}
      \setlength{\parskip}{0.4em}
      \pagestyle{plain}
    TEX

    # Minimal pandoc template: pandoc 3.x dropped the `titleblock` variable, so
    # the title block is assembled explicitly. No <head>/<style> — the site's
    # own stylesheet styles .tex-html.
    TEMPLATE = <<~'HTML'.freeze
      $if(title)$
      <header class="tex-titleblock">
      <h1 class="title">$title$</h1>
      $for(author)$
      <p class="author">$author$</p>
      $endfor$
      $if(date)$
      <p class="date">$date$</p>
      $endif$
      </header>
      $endif$
      $if(abstract)$
      <section class="tex-abstract"><h1 class="unnumbered">Abstract</h1>$abstract$</section>
      $endif$
      $body$
    HTML

    def self.full_document(source)
      return source if source =~ /\\documentclass/
      [DEFAULT_PREAMBLE, "\\begin{document}", source, "\\end{document}"].join("\n")
    end

    def self.available?(bin)
      system("which #{bin} > /dev/null 2>&1")
    end

    # Returns [html, nil] on success or [nil, error_html] on failure.
    def self.render(site, source, label)
      baseurl = site.baseurl.to_s
      doc     = full_document(source)
      sha     = Digest::SHA256.hexdigest("#{CACHE_VERSION}:#{doc}")[0, 16]
      cache   = File.join(site.source, ".jekyll-cache", "tex", sha)
      FileUtils.mkdir_p(cache)

      # ---- primary: pandoc -> HTML (real page content) --------------------
      html, pandoc_err = pandoc_html(site, source, cache)
      return [nil, error_html(site, cache, label, "pandoc conversion failed — #{pandoc_err}")] unless html

      # ---- secondary: pdfLaTeX -> PDF (for download) ----------------------
      pdf_path = File.join(cache, "paper.pdf")
      pdf_failed = nil
      unless File.file?(pdf_path)
        File.write(File.join(cache, "paper.tex"), doc)
        if available?(PDFLATEX)
          compile_pdf(cache)
          pdf_failed = "pdfLaTeX produced no PDF (see log below)." unless File.file?(pdf_path)
        else
          pdf_failed = "#{PDFLATEX} is not on PATH — PDF download unavailable."
        end
      end

      pages = nil
      pdf_name = nil
      if File.file?(pdf_path)
        pdf_name = "#{safe_name(label)}.pdf"
        asset_dir = File.join(site.dest, "assets", "tex", sha)
        staged = site.instance_variable_get(:@tex_staged) || []
        staged << [[pdf_path, File.join(asset_dir, pdf_name)]]
        site.instance_variable_set(:@tex_staged, staged)
        pages = pdf_page_count(pdf_path)
      end

      [success_html(site, source, html, label, baseurl, sha, pdf_name, pages, pdf_failed, cache), nil]
    rescue StandardError => e
      [nil, %(<div class="tex-paper tex-error">TeX plugin error: #{CGI.escapeHTML(e.message)}</div>)]
    end

    def self.pandoc_html(site, source, cache)
      html_path = File.join(cache, "paper.html")
      return [File.read(html_path), nil] if File.file?(html_path)

      tpl = File.join(site.source, ".jekyll-cache", "tex", "_template.html")
      File.write(tpl, TEMPLATE) unless File.file?(tpl)
      out, err, st = Open3.capture3(PANDOC, "-s", "--template=#{tpl}", "-f", "latex",
                                    "-t", "html5", "--mathjax", stdin_data: source)
      unless st.success?
        return [nil, err.to_s.lines.last(25).join]
      end

      html = fix_citations(out, source)
      html = fix_eqrefs(html)
      html = fix_bibliography(html)
      File.write(html_path, html)
      [html, nil]
    rescue Errno::ENOENT
      [nil, "#{PANDOC} not found on PATH"]
    end

    def self.compile_pdf(cache)
      2.times do
        system(PDFLATEX, "-interaction=nonstopmode", "-halt-on-error",
               "-file-line-error", "-output-directory", cache,
               File.join(cache, "paper.tex"),
               out: File::NULL, err: File::NULL)
        break if File.file?(File.join(cache, "paper.pdf"))
      end
    end

    def self.pdf_page_count(pdf)
      return nil unless available?(PDFINFO)
      out, _, st = Open3.capture3(PDFINFO, pdf)
      return nil unless st.success?
      m = out[/^Pages:\s+(\d+)/i, 1]
      m ? m.to_i : nil
    end

    def self.safe_name(label)
      n = label.to_s.gsub(/[^a-zA-Z0-9_.-]/, "-").sub(/\A-+/, "").sub(/-+\z/, "")
      n = "paper" if n.empty?
      n
    end

    # ---- post-processing of the pandoc fragment --------------------------

    # pandoc leaves empty <span class="citation" data-cites="key"> markers unless
    # citeproc runs. Number them against the \bibitem order in the source.
    def self.fix_citations(html, source)
      keys = source.scan(/\\bibitem\{([^}]+)\}/).flatten.map(&:strip)
      return html if keys.empty?
      index = keys.each_with_index.to_h { |k, i| [k, i + 1] }
      html.gsub(/<span\s+class="citation"\s+data-cites="([^"]+)">.*?<\/span>/m) do |_m|
        nums = Regexp.last_match(1).split(/\s+/).map { |c| index[c.strip] }.compact
        nums.empty? ? "[?]" : "[#{nums.join(', ')}]"
      end
    end

    # pandoc renders \eqref{lab} as <a href="#lab" data-reference-type="eqref"
    # data-reference="lab">[lab]</a>. MathJax (tags: ams) numbers labeled
    # equations in document order, so count display equations and substitute
    # the real number; point the anchor at MathJax's mjx-eqn-<label> id.
    def self.fix_eqrefs(html)
      labels = {}
      counter = 0
      html.scan(/<span class="math display">(.*?)<\/span>/m) do |m|
        math = m[0]
        counter += 1 if math =~ /\\begin\{(equation|align|gather|eqnarray)\}(?!\*)/
        if (lab = math[/\\label\{([^}]+)\}/, 1])
          labels[lab] = counter
        end
      end
      return html if labels.empty?
      html.gsub(/<a\s+href="#[^"]+"\s+data-reference-type="eqref"\s+data-reference="([^"]+)">[^<]*<\/a>/m) do |_m|
        lab = Regexp.last_match(1)
        n = labels[lab]
        n ? %(<a href="#mjx-eqn-#{lab}" class="tex-eqref">(#{n})</a>) : Regexp.last_match(0)
      end
    end

    # Tidy thebibliography: drop pandoc's stray width-label <p>, add a
    # References heading, and number each entry.
    def self.fix_bibliography(html)
      return html unless html.include?("thebibliography")
      html = html.sub(/<div class="thebibliography">\s*<p><span>\d+<\/span><\/p>/,
                      '<div class="tex-references"><h1 class="unnumbered">References</h1>')
      n = 0
      html.gsub(/<div class="tex-references">(.*?)<\/div>/m) do
        body = Regexp.last_match(1).gsub(/<p>(.*?)<\/p>/m) do
          n += 1
          %(<p><span class="tex-bibnum">[#{n}]</span>#{Regexp.last_match(1)}</p>)
        end
        %(<div class="tex-references">#{body}</div>)
      end
    end

    # ---- rendering --------------------------------------------------------

    def self.success_html(site, source, html, label, baseurl, sha, pdf_name, pages, pdf_failed, cache)
      meta = if pdf_failed
               "HTML · pdfLaTeX failed"
             elsif pages
               "#{pages} pp · pdfLaTeX"
             else
               "pdfLaTeX"
             end

      begin
        lexer = Rouge::Lexers::Tex.new
        source_html = Rouge::Formatters::HTML.new.format(lexer.lex(source))
      rescue StandardError
        source_html = CGI.escapeHTML(source)
      end

      out = +%(<div class="tex-paper" data-tex-label="#{CGI.escapeHTML(label)}">)
      out << %(<div class="tex-toolbar">)
      out << %(<span class="tex-label"><i class="fa-solid fa-file-lines"></i> LaTeX</span>)
      out << %(<span class="tex-meta">#{meta}</span>)
      out << %(<span class="tex-actions">)
      if pdf_failed
        out << %(<span class="tex-pdf-warn" title="#{CGI.escapeHTML(pdf_failed)}"><i class="fa-solid fa-triangle-exclamation"></i> PDF failed</span>)
      else
        out << %(<a class="tex-download" href="#{baseurl}/assets/tex/#{sha}/#{pdf_name}" download title="Download compiled PDF"><i class="fa-solid fa-download"></i> .pdf</a>)
      end
      out << %(</span>)
      out << %(</div>)
      out << %(<div class="tex-html">#{html}</div>)

      if pdf_failed && cache && File.file?(File.join(cache, "paper.log"))
        log_tail = File.read(File.join(cache, "paper.log")).lines.last(60).join
        out << %(<details class="tex-source tex-error-log"><summary><i class="fa-solid fa-bug"></i> pdfLaTeX log</summary><pre><code>#{CGI.escapeHTML(log_tail)}</code></pre></details>) unless log_tail.empty?
      end

      out << %(<details class="tex-source"><summary><i class="fa-solid fa-code"></i> .tex source</summary><pre class="highlight"><code>#{source_html}</code></pre></details>)
      out << %(</div>)
      out
    end

    def self.error_html(site, cache, label, message)
      log_tail = ""
      if cache && File.file?(File.join(cache, "paper.log"))
        log_tail = File.read(File.join(cache, "paper.log")).lines.last(60).join
      end
      html = +%(<div class="tex-paper tex-error">)
      html << %(<div class="tex-toolbar"><span class="tex-label"><i class="fa-solid fa-file-lines"></i> LaTeX</span><span class="tex-meta">render failed</span></div>)
      html << %(<div class="tex-error-body"><strong>#{CGI.escapeHTML(message)}</strong>#{label ? " — <code>#{CGI.escapeHTML(label)}</code>" : ""}</div>)
      unless log_tail.empty?
        html << %(<details class="tex-source tex-error-log"><summary><i class="fa-solid fa-bug"></i> pdfLaTeX log</summary><pre><code>#{CGI.escapeHTML(log_tail)}</code></pre></details>)
      end
      html << %(</div>)
      html
    end
  end

  # Inline LaTeX cell — {% tex_cell [label=...] %} ... {% endtex_cell %}
  class TexCellBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @label = "paper"
      markup.to_s.split(",").map(&:strip).each do |opt|
        key, _, val = opt.partition("=")
        @label = val.strip if key.downcase == "label" && !val.strip.empty?
      end
    end

    def render(context)
      site = context.registers[:site]
      raw  = super.to_s.sub(/\A\s*\n/, "").sub(/\n\s*\z/, "")
      html, err = TexEngine.render(site, raw, @label)
      wrap_nomarkdown(html || err)
    end

    def wrap_nomarkdown(html)
      "\n\n{::nomarkdown}\n#{html}\n{:/nomarkdown}\n\n"
    end
  end

  # Compile an external .tex file — {% tex_file "/assets/papers/foo.tex" %}
  class TexFileTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @raw = markup.to_s.strip
    end

    def render(context)
      site = context.registers[:site]
      path = parse_path(@raw, context)
      abs  = File.join(site.source, path.sub(%r{\A/}, ""))
      unless File.file?(abs)
        return "\n\n{::nomarkdown}\n<div class=\"tex-paper tex-error\">TeX file not found: #{CGI.escapeHTML(path)}</div>\n{:/nomarkdown}\n\n"
      end
      html, err = TexEngine.render(site, File.read(abs), File.basename(abs, ".tex"))
      "\n\n{::nomarkdown}\n#{html || err}\n{:/nomarkdown}\n\n"
    end

    def parse_path(markup, context)
      m = markup.match(/\A"([^"]+)"\z/) || markup.match(/\A'([^']+)'\z/)
      return m[1] if m
      Liquid::Template.parse("{{ #{markup} }}").render(context).strip
    end
  end
end

Liquid::Template.register_tag("tex_cell", Jekyll::TexCellBlock)
Liquid::Template.register_tag("tex_file", Jekyll::TexFileTag)

Jekyll::Hooks.register :site, :post_write do |site|
  staged = site.instance_variable_get(:@tex_staged)
  next unless staged
  staged.each do |copies|
    copies.each do |src, dst|
      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.cp(src, dst)
    end
  end
end
