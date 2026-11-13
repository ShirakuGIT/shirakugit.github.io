# From: https://github.com/ainc/awesomeinc2013/blob/master/Rakefile 

require "rubygems"
require "tmpdir"

require "bundler/setup"
require "jekyll"

ENV["JEKYLL_ENV"] = "production"

desc "Generate blog files"
task :generate do
  Jekyll::Site.new(Jekyll.configuration({
    "source"      => ".",
    "destination" => "_site"
  })).process
end


desc "Generate and publish blog to gh-pages"
# Builds a clean checkout of HEAD in a temp dir, so the deploy contains exactly
# what is committed (no untracked files) and never races a running
# `jekyll serve` that also writes to _site/.
task :publish do
  abort "Uncommitted changes to tracked files — commit them first." unless `git status --porcelain --untracked-files=no`.strip.empty?
  head = `git rev-parse --short HEAD`.strip
  Dir.mktmpdir do |tmp|
    src = File.join(tmp, "src")
    out = File.join(tmp, "out")
    system("git", "worktree", "add", "--detach", "-q", src, "HEAD") or abort "git worktree add failed"
    begin
      Jekyll::Site.new(Jekyll.configuration({
        "source"      => src,
        "destination" => out
      })).process
    ensure
      system("git", "worktree", "remove", "--force", src)
    end

    pwd = Dir.pwd
    Dir.chdir out

    system "git init -q"
    system "git checkout -q -b gh-pages"
    system "git add ."
    message = "Site updated at #{Time.now.utc} (main #{head})"
    system "git commit -q -m #{message.inspect}"
    system "git remote add origin https://www.github.com/ShirakuGIT/shirakugit.github.io.git"
    system "git push origin gh-pages --force"

    Dir.chdir pwd
  end
end
