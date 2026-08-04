# TeX / LaTeX compilation for Jekyll — compile research-grade LaTeX into PDF
# and render it in place, notebook-cell style.
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
# Anything after {% tex_cell %} is wrapped in a small article preamble unless
# it already contains \documentclass. The document is compiled with pdfLaTeX,
# every page is rasterised to PNG, and the PDF is staged next to it so it can
# be downloaded. Builds are cached in .jekyll-cache/tex/<sha>/ and only
# recompiled when the source changes.
#
# Requires: pdflatex (TeX Live), pdftoppm (poppler). Override the binaries
# with the PDFLATEX / PDFTOPPM environment variables.
require "cgi"
require "digest"
require "fileutils"

module Jekyll
  module TexEngine
    PDFLATEX = ENV.fetch("PDFLATEX", "pdflatex")
    PDFTOPPM = ENV.fetch("PDFTOPPM", "pdftoppm")
    RENDER_DPI = 150

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

    def self.full_document(source)
      return source if source =~ /\\documentclass/
      [DEFAULT_PREAMBLE, "\\begin{document}", source, "\\end{document}"].join("\n")
    end

    def self.available?(bin)
      system("which #{bin} > /dev/null 2>&1")
    end

    # Renders one LaTeX document. Returns [html, nil] on success or
    # [nil, html] with an error card on failure.
    def self.render(site, source, label)
      unless available?(PDFLATEX)
        return [nil, error_html(site, nil, label,
                                "pdfLaTeX not found. #{CGI.escapeHTML(PDFLATEX)} must be on PATH to compile TeX.")]
      end

      baseurl   = site.baseurl.to_s
      doc       = full_document(source)
      sha       = Digest::SHA256.hexdigest(doc)[0, 16]
      cache_dir = File.join(site.source, ".jekyll-cache", "tex", sha)
      pdf_path  = File.join(cache_dir, "paper.pdf")

      unless File.file?(pdf_path)
        FileUtils.mkdir_p(cache_dir)
        tex_path = File.join(cache_dir, "paper.tex")
        File.write(tex_path, doc)
        compile(cache_dir, tex_path, pdf_path)
      end

      unless File.file?(pdf_path)
        return [nil, error_html(site, cache_dir, label, "Compilation failed — pdfLaTeX produced no PDF.")]
      end

      pages = Dir.glob(File.join(cache_dir, "page-*.png")).sort
      if pages.empty? && available?(PDFTOPPM)
        system(PDFTOPPM, "-png", "-r", RENDER_DPI.to_s, pdf_path, File.join(cache_dir, "page"),
               out: File::NULL, err: File::NULL)
        pages = Dir.glob(File.join(cache_dir, "page-*.png")).sort
      end

      # Jekyll's Cleaner deletes anything in _site that isn't a registered site
      # file, and it runs between render and write. So we defer the copy to a
      # post_write hook — by then the destination is final.
      asset_dir = File.join(site.dest, "assets", "tex", sha)
      pdf_name  = "#{safe_name(label)}.pdf"
      copies    = [[pdf_path, File.join(asset_dir, pdf_name)]]
      copies.concat(pages.map { |p| [p, File.join(asset_dir, File.basename(p))] })
      staged    = site.instance_variable_get(:@tex_staged) || []
      staged   << copies
      site.instance_variable_set(:@tex_staged, staged)

      [success_html(site, source, pages, "#{baseurl}/assets/tex/#{sha}", pdf_name, label), nil]
    rescue StandardError => e
      [nil, %(<div class="tex-paper tex-error">TeX plugin error: #{CGI.escapeHTML(e.message)}</div>)]
    end

    def self.compile(cache_dir, tex_path, pdf_path)
      2.times do
        system(PDFLATEX, "-interaction=nonstopmode", "-halt-on-error",
               "-file-line-error", "-output-directory", cache_dir, tex_path,
               out: File::NULL, err: File::NULL)
        break if File.file?(pdf_path)
      end
    end

    def self.safe_name(label)
      n = label.to_s.gsub(/[^a-zA-Z0-9_.-]/, "-").sub(/\A-+/, "").sub(/-+\z/, "")
      n = "paper" if n.empty?
      n
    end

    def self.error_html(site, cache_dir, label, message)
      log_tail = ""
      if cache_dir && File.file?(File.join(cache_dir, "paper.log"))
        log_tail = File.read(File.join(cache_dir, "paper.log")).lines.last(60).join
      end
      html = +%(<div class="tex-paper tex-error">)
      html << %(<div class="tex-toolbar"><span class="tex-label"><i class="fa-solid fa-file-lines"></i> LaTeX</span><span class="tex-meta">compile failed</span></div>)
      html << %(<div class="tex-error-body"><strong>#{CGI.escapeHTML(message)}</strong>#{label ? " — <code>#{CGI.escapeHTML(label)}</code>" : ""}</div>)
      unless log_tail.empty?
        html << %(<details class="tex-source tex-error-log"><summary><i class="fa-solid fa-bug"></i> pdfLaTeX log</summary><pre><code>#{CGI.escapeHTML(log_tail)}</code></pre></details>)
      end
      html << %(</div>)
      html
    end

    def self.success_html(site, source, pages, asset_url, pdf_name, label)
      pages_html = pages.map do |p|
        %(<div class="tex-page"><img src="#{asset_url}/#{File.basename(p)}" alt="#{CGI.escapeHTML(label)} page" loading="lazy"/></div>)
      end.join("\n")

      begin
        lexer  = Rouge::Lexers::Tex.new
        source_html = Rouge::Formatters::HTML.new.format(lexer.lex(source))
      rescue StandardError
        source_html = CGI.escapeHTML(source)
      end

      html = +%(<div class="tex-paper" data-tex-label="#{CGI.escapeHTML(label)}">)
      html << %(<div class="tex-toolbar">)
      html << %(<span class="tex-label"><i class="fa-solid fa-file-lines"></i> LaTeX</span>)
      html << %(<span class="tex-meta">#{pages.size} page#{pages.size == 1 ? "" : "s"} · pdfLaTeX</span>)
      html << %(<span class="tex-actions">)
      html << %(<a class="tex-download" href="#{asset_url}/#{pdf_name}" download title="Download compiled PDF"><i class="fa-solid fa-download"></i> .pdf</a>)
      html << %(</span>)
      html << %(</div>)
      html << %(<div class="tex-pages">#{pages_html}</div>)
      html << %(<details class="tex-source"><summary><i class="fa-solid fa-code"></i> .tex source</summary><pre class="highlight"><code>#{source_html}</code></pre></details>)
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
