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
task :publish => [:generate] do
  Dir.mktmpdir do |tmp|
    cp_r "_site/.", tmp

    pwd = Dir.pwd
    Dir.chdir tmp

    system "git init -q"
    system "git checkout -q -b gh-pages"
    system "git add ."
    message = "Site updated at #{Time.now.utc}"
    system "git commit -q -m #{message.inspect}"
    system "git remote add origin https://www.github.com/ShirakuGIT/shirakugit.github.io.git"
    system "git push origin gh-pages --force"

    Dir.chdir pwd
  end
end
