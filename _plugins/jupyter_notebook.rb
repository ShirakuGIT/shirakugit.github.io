require "json"
require "kramdown"
require "rouge"
require "cgi"

module Jekyll
  class JupyterNotebookTag < Liquid::Tag
    SUPPORTED_LANGS = %w[python ruby bash sh r julia javascript js c cpp rust go].freeze

    def initialize(tag_name, markup, tokens)
      super
      @raw = markup.to_s.strip
    end

    def render(context)
      site = context.registers[:site]
      path = parse_path(@raw, context)
      abs  = resolve_path(site, path)

      unless File.file?(abs)
        return %(<div class="jupyter-notebook jupyter-error">Notebook not found: #{CGI.escapeHTML(path)}</div>)
      end

      nb = JSON.parse(File.read(abs))
      lang = (nb.dig("metadata", "kernelspec", "language") ||
              nb.dig("metadata", "language_info", "name") || "python").to_s.downcase
      lang = "python" unless SUPPORTED_LANGS.include?(lang)

      cells = nb["cells"] || []
      rel   = relative_url(site, abs)
      out   = +%(<div class="jupyter-notebook" data-src="#{CGI.escapeHTML(rel)}">)
      out << %(<div class="jupyter-toolbar"><a href="#{CGI.escapeHTML(rel)}" download class="jupyter-download" title="Download .ipynb"><i class="fa-solid fa-download"></i> .ipynb</a></div>)

      cells.each do |cell|
        case cell["cell_type"]
        when "markdown" then out << render_markdown(join(cell["source"]))
        when "code"     then out << render_code(cell, lang)
        when "raw"      then out << render_raw(join(cell["source"]))
        end
      end

      out << "</div>"
      wrap_nomarkdown(out)
    rescue JSON::ParserError => e
      wrap_nomarkdown(%(<div class="jupyter-notebook jupyter-error">Invalid .ipynb JSON: #{CGI.escapeHTML(e.message)}</div>))
    end

    private

    # kramdown with parse_block_html: true mangles block-level HTML — wrap
    # output so kramdown emits it verbatim. Newlines around the markers are
    # required for kramdown to treat them as block-level.
    def wrap_nomarkdown(html)
      "\n\n{::nomarkdown}\n#{html}\n{:/nomarkdown}\n\n"
    end

    def parse_path(markup, context)
      m = markup.match(/\A"([^"]+)"\z/) || markup.match(/\A'([^']+)'\z/)
      return m[1] if m
      # support Liquid variable like: {% jupyter_notebook page.notebook %}
      Liquid::Template.parse("{{ #{markup} }}").render(context).strip
    end

    def resolve_path(site, path)
      stripped = path.sub(%r{\A/}, "")
      File.join(site.source, stripped)
    end

    def relative_url(site, abs)
      "/" + abs.sub(/\A#{Regexp.escape(site.source)}\/?/, "")
    end

    def join(src)
      src.is_a?(Array) ? src.join("") : src.to_s
    end

    def render_markdown(text)
      html = Kramdown::Document.new(text, input: "GFM", math_engine: "mathjax").to_html
      %(<div class="jupyter-cell jupyter-markdown">#{html}</div>)
    end

    def render_raw(text)
      %(<div class="jupyter-cell jupyter-raw"><pre>#{CGI.escapeHTML(text)}</pre></div>)
    end

    def render_code(cell, lang)
      src = join(cell["source"])
      exec_count = cell["execution_count"]
      prompt_in  = exec_count ? "In&nbsp;[#{exec_count}]:" : "In&nbsp;[&nbsp;]:"

      formatter = Rouge::Formatters::HTML.new
      lexer     = Rouge::Lexer.find(lang) || Rouge::Lexers::PlainText.new
      lexer     = lexer.new if lexer.is_a?(Class)
      highlighted = formatter.format(lexer.lex(src))

      out = +%(<div class="jupyter-cell jupyter-code">)
      out << %(<div class="jupyter-prompt jupyter-prompt-in">#{prompt_in}</div>)
      out << %(<div class="jupyter-input"><pre class="highlight"><code>#{highlighted}</code></pre></div>)

      outputs = cell["outputs"] || []
      unless outputs.empty?
        out << %(<div class="jupyter-output-block">)
        outputs.each { |o| out << render_output(o, exec_count) }
        out << "</div>"
      end
      out << "</div>"
      out
    end

    def render_output(o, exec_count)
      case o["output_type"]
      when "stream"
        stream_class = o["name"] == "stderr" ? "jupyter-stderr" : "jupyter-stdout"
        %(<pre class="jupyter-output #{stream_class}">#{CGI.escapeHTML(join(o["text"]))}</pre>)
      when "execute_result", "display_data"
        render_mimebundle(o["data"] || {}, o["output_type"], exec_count)
      when "error"
        tb = (o["traceback"] || []).map { |t| strip_ansi(t) }.join("\n")
        %(<pre class="jupyter-output jupyter-error-output">#{CGI.escapeHTML(tb)}</pre>)
      else
        ""
      end
    end

    def render_mimebundle(data, output_type, exec_count)
      prompt = output_type == "execute_result" && exec_count ?
        %(<div class="jupyter-prompt jupyter-prompt-out">Out[#{exec_count}]:</div>) : ""

      # priority: html > image/svg+xml > image/png > image/jpeg > latex > markdown > text
      body =
        if data["text/html"]
          %(<div class="jupyter-output jupyter-html">#{join(data["text/html"])}</div>)
        elsif data["image/svg+xml"]
          %(<div class="jupyter-output jupyter-image">#{join(data["image/svg+xml"])}</div>)
        elsif data["image/png"]
          %(<div class="jupyter-output jupyter-image"><img alt="output" src="data:image/png;base64,#{join(data["image/png"]).gsub(/\s+/, "")}"/></div>)
        elsif data["image/jpeg"]
          %(<div class="jupyter-output jupyter-image"><img alt="output" src="data:image/jpeg;base64,#{join(data["image/jpeg"]).gsub(/\s+/, "")}"/></div>)
        elsif data["text/latex"]
          %(<div class="jupyter-output jupyter-latex">#{join(data["text/latex"])}</div>)
        elsif data["text/markdown"]
          html = Kramdown::Document.new(join(data["text/markdown"]), input: "GFM").to_html
          %(<div class="jupyter-output jupyter-md">#{html}</div>)
        elsif data["text/plain"]
          %(<pre class="jupyter-output jupyter-plain">#{CGI.escapeHTML(join(data["text/plain"]))}</pre>)
        else
          ""
        end
      prompt + body
    end

    def strip_ansi(s)
      s.gsub(/\e\[[0-9;]*[A-Za-z]/, "")
    end
  end
end

Liquid::Template.register_tag("jupyter_notebook", Jekyll::JupyterNotebookTag)

module Jekyll
  # Inline notebook-style cell — no .ipynb file required.
  #
  # Syntax (block tag):
  #
  #   {% nb_cell python %}
  #   import numpy as np
  #   np.array([1, 2, 3]).sum()
  #   ---out
  #   6
  #   {% endnb_cell %}
  #
  # Output sentinels (each starts at column 0, case-insensitive):
  #   ---out           plain text output (stdout-style, green border)
  #   ---err           stderr / traceback (orange border)
  #   ---img <path>    image output (path relative to site root)
  #   ---html          raw HTML output (DataFrames, tables, etc.)
  #
  # Multiple sentinels per cell are allowed and rendered in order.
  # Auto-numbered In[n]:/Out[n]: prompts (per page render).
  # Pass `no_prompt` after the language to drop the In[n]:/Out[n]: gutter:
  #
  #   {% nb_cell python, no_prompt %} ... {% endnb_cell %}
  class NbCellBlock < Liquid::Block
    SUPPORTED_LANGS = JupyterNotebookTag::SUPPORTED_LANGS
    SENTINEL = /^\s*---\s*(out|err|img|html)(?:\s+(.+?))?\s*$/i

    def initialize(tag_name, markup, tokens)
      super
      args = markup.to_s.split(",").map(&:strip)
      @lang = (args.shift || "python").downcase
      @lang = "python" unless SUPPORTED_LANGS.include?(@lang)
      @flags = args
    end

    def render(context)
      raw = super.to_s
      input, outputs = split_cell(raw)
      input = input.sub(/\A\n+/, "").sub(/\n+\z/, "")

      no_prompt = @flags.include?("no_prompt")
      context.registers[:nb_counter] ||= 0
      context.registers[:nb_counter] += 1
      n = context.registers[:nb_counter]

      formatter = Rouge::Formatters::HTML.new
      lexer     = Rouge::Lexer.find(@lang) || Rouge::Lexers::PlainText.new
      lexer     = lexer.new if lexer.is_a?(Class)
      highlighted = formatter.format(lexer.lex(input))

      grid_class = no_prompt ? "jupyter-cell jupyter-code jupyter-noprompt" : "jupyter-cell jupyter-code"
      html = +%(<div class="#{grid_class}">)
      html << %(<div class="jupyter-prompt jupyter-prompt-in">In&nbsp;[#{n}]:</div>) unless no_prompt
      html << %(<div class="jupyter-input"><pre class="highlight"><code>#{highlighted}</code></pre></div>)

      unless outputs.empty?
        html << %(<div class="jupyter-output-block">)
        html << %(<div class="jupyter-prompt jupyter-prompt-out">Out[#{n}]:</div>) unless no_prompt
        outputs.each do |o|
          html << render_output_part(o)
        end
        html << "</div>"
      end
      html << "</div>"

      "\n\n{::nomarkdown}\n#{html}\n{:/nomarkdown}\n\n"
    end

    private

    def split_cell(raw)
      lines = raw.split("\n", -1)
      input_lines = []
      outputs = []
      current = nil
      lines.each do |line|
        if (m = line.match(SENTINEL))
          outputs << current if current
          current = { kind: m[1].downcase, arg: m[2], body: [] }
        elsif current
          current[:body] << line
        else
          input_lines << line
        end
      end
      outputs << current if current
      outputs.each { |o| o[:body] = o[:body].join("\n").sub(/\A\n+/, "").sub(/\n+\z/, "") }
      [input_lines.join("\n"), outputs]
    end

    def render_output_part(o)
      case o[:kind]
      when "out"
        %(<pre class="jupyter-output jupyter-stdout">#{CGI.escapeHTML(o[:body])}</pre>)
      when "err"
        %(<pre class="jupyter-output jupyter-error-output">#{CGI.escapeHTML(o[:body])}</pre>)
      when "img"
        path = o[:arg].to_s.strip
        %(<div class="jupyter-output jupyter-image"><img alt="output" src="#{CGI.escapeHTML(path)}"/></div>)
      when "html"
        %(<div class="jupyter-output jupyter-html">#{o[:body]}</div>)
      else
        ""
      end
    end
  end

  # Reset the In[]/Out[] counter mid-page if desired.
  #   {% nb_reset %}
  class NbResetTag < Liquid::Tag
    def render(context)
      context.registers[:nb_counter] = 0
      ""
    end
  end
end

Liquid::Template.register_tag("nb_cell", Jekyll::NbCellBlock)
Liquid::Template.register_tag("nb_reset", Jekyll::NbResetTag)
