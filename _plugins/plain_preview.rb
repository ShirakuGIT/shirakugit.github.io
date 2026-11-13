# Design prototypes: renders the home index and every post/note under
# /plain/<style>/ (the "plain" style lives at /plain/ itself). All styles share
# the same markup (_layouts/plain.html, _includes/plain/*); only the stylesheet
# in assets/plain/<style>.css changes. Development builds only — production
# builds (JEKYLL_ENV=production, as `rake publish` uses) contain none of it.
# Remove this file, that layout, those includes, _pages/plain-fonts.html,
# _data/plain_fonts.yml and assets/plain/ to drop the prototypes entirely.
module PlainPreview
  STYLES = %w[plain sidebar book contents homepage swiss man paper].freeze

  class Generator < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      # Design prototypes are a local tool: keep them out of production builds.
      if Jekyll.env == "production"
        site.pages.reject! { |p| p.url.start_with?("/plain/") }
        site.static_files.reject! { |f| f.relative_path.start_with?("/assets/plain/") }
        return
      end
      site.config["plain_styles"] = STYLES # read by the style switcher in the layout
      docs = site.posts.docs + site.collections["notes"].docs
      STYLES.each do |style|
        base = style == "plain" ? "/plain" : "/plain/#{style}"
        site.pages << build(site, base, "index.html", style, base, "index", nil, site.config["title"])
        docs.each do |doc|
          url = base + doc.url
          dir, name = url.end_with?("/") ? [url, "index.html"] : [File.dirname(url), File.basename(url)]
          site.pages << build(site, dir, name, style, base, "article", doc.url, doc.data["title"])
        end
      end
    end

    private

    def build(site, dir, name, style, base, kind, doc_url, title)
      page = Jekyll::PageWithoutAFile.new(site, site.source, dir, name)
      page.content = "{% include plain/#{kind}.html %}"
      page.data.merge!(
        "layout" => "plain", "style" => style, "base" => base, "doc_url" => doc_url,
        "title" => title, "sitemap" => false, "search" => false, "math" => kind == "article"
      )
      page
    end
  end
end
