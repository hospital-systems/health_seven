Gem::Specification.new do |spec|
  spec.name = "health_seven"
  spec.version = "0.0.3"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Ruby library for hl7 2.x"
  spec.files =  Dir.glob("{lib,spec}/**/**/*") +
                      ['health_seven.gemspec']
  spec.require_path = "lib"
  spec.required_ruby_version = '>= 1.9.1'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.test_files = Dir[ "spec/*_spec.rb" ]
  spec.authors = ["Nikolay Ryzhikov", "Dmitry Rybakov"]
  spec.email = ["niquola@gmail.com"]
  spec.add_dependency('treetop')
  spec.description = 'Ruby library for HL7 2.x'
  spec.post_install_message = ''
  spec.homepage = 'https://github.com/hospital-systems/health_seven'
end
