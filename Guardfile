# -*- ruby -*-

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :minitest do
  # with Minitest::Spec
  watch(%r{\Aspec/(.*)_spec\.rb})
  watch(%r{\Alib/(?:\w+/)*([^/]+)\.rb}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{\Aspec/spec_helper\.rb})     { 'spec' }
end
