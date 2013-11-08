Gem::Specification.new do |s|
  s.name          = 'textmood'
  s.version       = '0.0.4'
  s.date          = '2013-11-08'
  s.summary       = "TextMood"
  s.description   = "Simple sentiment analyzer with CLI tool"
  s.authors       = ["Stian Grytoyr"]
  s.email         = 'stian@grytoyr.net'
  s.homepage      = 'https://github.com/stiang/textmood'
  s.license       = 'MIT'
  s.require_paths = %w[lib]
  s.executables   = ["textmood"]
  s.files         = Dir["{lib}/**/*.rb", "lang/*", "bin/*", "test/*", "*.md", "LICENSE"]
  s.test_files    = s.files.select { |path| path =~ /^test\/test.*\.rb/ }
end
