Autotest.add_hook :initialize do |att|
  att.clear_mappings

  att.add_mapping(%r%^(test|spec)/.*\.rb$%) do |filename, _|
    filename
  end

  att.add_mapping(%r%^lib/(.*)\.rb$%) do |filename, m|
    ["test/test_#{m[1]}.rb", "test/spec_#{m[1]}.rb", "spec/spec_#{m[1]}.rb"]
  end

  false
end

class Autotest::Bacon < Autotest
  def initialize
    super
    self.libs = %w[. lib test spec].join(File::PATH_SEPARATOR)
  end

  def make_test_cmd(files_to_test)
    args = files_to_test.keys.flatten.join(' ')
    args = '-a' if args.empty?
    # TODO : make regex to pass to -n using values
    "#{ruby} -S bacon -o TestUnit #{args}"
  end
end