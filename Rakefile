# Rakefile for Bacon.  -*-ruby-*-
require 'rake/rdoctask'
require 'rake/testtask'


desc "Run all the tests"
task :default => [:test]

desc "Do predistribution stuff"
task :predist => [:chmod, :changelog, :rdoc]


desc "Make an archive as .tar.gz"
task :dist => :test do
  sh "export DARCS_REPO=#{File.expand_path "."}; " +
     "darcs dist -d bacon-#{get_darcs_tree_version}"
end

# Helper to retrieve the "revision number" of the darcs tree.
def get_darcs_tree_version
  unless File.directory? "_darcs"
    $: << "lib"
    require 'bacon'
    return Bacon::VERSION
  end

  changes = `darcs changes`
  count = 0
  tag = "0.0"

  changes.each("\n\n") { |change|
    head, title, desc = change.split("\n", 3)

    if title =~ /^  \*/
      # Normal change.
      count += 1
    elsif title =~ /tagged (.*)/
      # Tag.  We look for these.
      tag = $1
      break
    else
      warn "Unparsable change: #{change}"
    end
  }

  tag + "." + count.to_s
end

def manifest
  `darcs query manifest 2>/dev/null`.split("\n").map { |f| f.gsub(/\A\.\//, '') }
end


desc "Make binaries executable"
task :chmod do
  Dir["bin/*"].each { |binary| File.chmod(0775, binary) }
end

desc "Generate a ChangeLog"
task :changelog do
  sh "darcs changes --repo=#{ENV["DARCS_REPO"] || "."} >ChangeLog"
end


desc "Generate RDox"
task "RDOX" do
  sh "bin/bacon -Ilib --automatic --specdox >RDOX"
end

desc "Run all the fast tests"
task :test do
  ruby "bin/bacon -Ilib --automatic --quiet"
end


begin
  $" << "sources"  if defined? FromSrc
  require 'rubygems'

  require 'rake'
  require 'rake/clean'
  require 'rake/packagetask'
  require 'rake/gempackagetask'
  require 'fileutils'
rescue LoadError
  # Too bad.
else
  spec = Gem::Specification.new do |s|
    s.name            = "bacon"
    s.version         = get_darcs_tree_version
    s.platform        = Gem::Platform::RUBY
    s.summary         = "a small RSpec clone"

    s.description = <<-EOF
Bacon is a small RSpec clone weighing less than 350 LoC but
nevertheless providing all essential features.

http://chneukirchen.org/repos/bacon
    EOF

    s.files           = manifest + %w(RDOX)
    s.bindir          = 'bin'
    s.executables     << 'bacon'
    s.require_path    = 'lib'
    s.has_rdoc        = true
    s.extra_rdoc_files = ['README', 'RDOX']
    s.test_files      = []

    s.author          = 'Christian Neukirchen'
    s.email           = 'chneukirchen@gmail.com'
    s.homepage        = 'http://chneukirchen.org/repos/bacon'
  end

  Rake::GemPackageTask.new(spec) do |p|
    p.gem_spec = spec
    p.need_tar = false
    p.need_zip = false
  end
end

desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' << 'Bacon Documentation' <<
    '--charset' << 'utf-8'
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include 'README'
  rdoc.rdoc_files.include 'COPYING'
  rdoc.rdoc_files.include 'RDOX'
  rdoc.rdoc_files.include('lib/bacon.rb')
end
task :rdoc => ["RDOX"]
