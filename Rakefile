# Rakefile for Bacon.  -*-ruby-*-
require 'rdoc/task'
require 'rake/testtask'


desc "Run all the tests"
task :default => [:test]

desc "Do predistribution stuff"
task :predist => [:chmod, :changelog, :rdoc]


desc "Make an archive as .tar.gz"
task :dist => [:test, :predist] do
  sh "git archive --format=tar --prefix=#{release}/ HEAD^{tree} >#{release}.tar"
  sh "pax -waf #{release}.tar -s ':^:#{release}/:' RDOX ChangeLog doc"
  sh "gzip -f -9 #{release}.tar"
end

# Helper to retrieve the "revision number" of the git tree.
def git_tree_version
  if File.directory?(".git")
    @tree_version ||= `git describe`.strip.sub('-', '.')
    @tree_version << ".0"  unless @tree_version.count('.') == 2
  else
    $: << "lib"
    require 'bacon'
    @tree_version = Bacon::VERSION
  end
  @tree_version
end

def gem_version
  git_tree_version.gsub(/-.*/, '')
end

def release
  "bacon-#{git_tree_version}"
end

def manifest
  `git ls-files`.split("\n") - [".gitignore"]
end


desc "Make binaries executable"
task :chmod do
  Dir["bin/*"].each { |binary| File.chmod(0775, binary) }
end

desc "Generate a ChangeLog"
task :changelog do
  sh "git log --format='%ad  %an <%ae>%n%w(79,2,4)* %s%n%n%w(76,4,4)%b' |grep -v darcs-hash: |cat -s >ChangeLog"
end


desc "Generate RDox"
task "RDOX" do
  sh "bin/bacon -Ilib --automatic --specdox >RDOX"
end

desc "Run all the tests"
task :test do
  ruby "bin/bacon -Ilib --automatic --quiet"
end


desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README.rdoc' <<
    '--title' << 'Bacon Documentation' <<
    '--charset' << 'utf-8'
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include 'README.rdoc'
  rdoc.rdoc_files.include 'COPYING'
  rdoc.rdoc_files.include 'RDOX'
  rdoc.rdoc_files.include('lib/bacon.rb')
end
task :rdoc => ["RDOX"]
