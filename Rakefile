require 'rake'
require 'rake/testtask'

$: << 'lib'
require 'saikuro_treemap'

namespace :metrics do
  desc 'generate ccn treemap'
  task :ccn_treemap do
    SaikuroTreemap.generate_treemap :code_dirs => ['lib']
    `open reports/saikuro_treemap.html`
  end
end

begin
  require 'rubygems'
rescue LoadError
  # Too bad.
else
  task "saikuro_treemap.gemspec" do
    spec = Gem::Specification.new do |s|
      s.name            = "saikuro_treemap"
      s.version         = 0.1
      s.platform        = Gem::Platform::RUBY
      s.summary         = "Generate CCN Treemap based on saikuro analysis"
      
      s.description = <<-EOF
      Generate CCN Treemap based on saikuro analysis
    EOF

      s.files           = `git ls-files`.split("\n") + %w(saikuro_treemap.gemspec)
      s.bindir          = 'bin'
      s.require_path    = 'lib'
      s.has_rdoc        = false
      s.extra_rdoc_files = ['README.textile']
      s.test_files      = Dir['test/{test,spec}_*.rb']
      
      s.author          = 'ThoughtWorks Studios'
      s.email           = 'studios@thoughtworks.com'
      s.homepage        = 'http://saikuro_treemap.rubyforge.org'
      s.rubyforge_project = 'saikuro_treemap'      
    end

    File.open("saikuro_treemap.gemspec", "w") { |f| f << spec.to_ruby }
  end

  task :gem => ["saikuro_treemap.gemspec"] do
    sh "gem build saikuro_treemap.gemspec"
  end
end

task :test do
  Rake::TestTask.new do |t|
     t.libs << "test"
     t.test_files = FileList['test/*test.rb']
     t.verbose = true
   end
end

task :default => :test