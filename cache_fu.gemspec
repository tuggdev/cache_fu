Gem::Specification.new do |s|
  s.name = 'cache_fu'
  s.version = '0.1.1'
  s.authors = [""]
  s.summary = 'Makes caching easy for ActiveRecord models'
  s.description = "This gem is kreetitech's fork (http://github.com/kreetitech/cache_fu)."
  s.email = ['']

  s.files = Dir.glob('{rails,lib,test,defaults}/**/*') +
                        %w(LICENSE README)
  s.homepage = 'http://github.com/kreetitech/cache_fu'
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails', '~> 3.0'

  s.add_development_dependency 'rails', '~> 3.0'
end
