Gem::Specification.new do |s|
  s.name            = "bacon"
  s.version         = '1.2.0'
  s.platform        = Gem::Platform::RUBY
  s.summary         = "a small RSpec clone"

  s.description = <<-EOF
Bacon is a small RSpec clone weighing less than 350 LoC but
nevertheless providing all essential features.

http://github.com/chneukirchen/bacon
  EOF

  s.files           = `git ls-files`.split("\n") - [".gitignore"] + %w(RDOX ChangeLog)
  s.bindir          = 'bin'
  s.executables     << 'bacon'
  s.require_path    = 'lib'
  s.has_rdoc        = true
  s.extra_rdoc_files = ['README.rdoc', 'RDOX']
  s.test_files      = []

  s.author          = 'Christian Neukirchen'
  s.email           = 'chneukirchen@gmail.com'
  s.homepage        = 'http://github.com/chneukirchen/bacon'
end
