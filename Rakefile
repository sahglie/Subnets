
begin
  require 'bundler'
  Bundler.setup(:default, :development)
  Bundler.require(:default, :development)    
rescue LoadError
  puts "Please install Bundler and run 'bundle install' to ensure you have all dependencies"
end
  
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'


Echoe.new('subnets', '0.0.1') do |p|
  p.description    = "API for quering subnets"
  p.url            = "http://ucbrb.rubyforge.org"
  p.author         = "Steven Hansen"
  p.email          = "runner AT berkeley DOT edu"
  p.project        = "ucbrb"
  p.rdoc_pattern   = "README.md", "lib/**/**", "TODO.md"
end

Spec::Rake::SpecTask.new("spec:rcov") do |t|
  t.spec_opts ||= []
  t.spec_opts << "--options" << "spec/spec.opts"
  t.rcov_opts ||= []
  t.rcov_opts << "--exclude" << "/gems/*," + Dir['spec/**/*.rb'].join(",")
  t.rcov = true
end

RCov::VerifyTask.new(:rcov => "spec:rcov") do |t|
  t.threshold = 100
end


