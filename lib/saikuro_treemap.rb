require 'rubygems'
require 'json/pure'
require 'erb'
require 'rake'
require 'base64'

require 'saikuro'
require 'saikuro_treemap/version'
require 'saikuro_treemap/parser'
require 'saikuro_treemap/ccn_node'

module SaikuroTreemap
  
  class SaikuroRake
    include ResultIndexGenerator
    
    def run(options)
      
      rm_rf options[:output_directory]
      
      state_filter = Filter.new(5)
      token_filter = Filter.new(10, 25, 50)
      
      state_filter.limit = options[:filter_cyclo] if options[:filter_cyclo]
      state_filter.warn = options[:warn_cyclo] if options[:warn_cyclo]
      state_filter.error = options[:error_cyclo] if options[:error_cyclo]
      
      token_filter.limit = options[:filter_token] if options[:filter_token]
      token_filter.warn = options[:warn_token] if options[:warn_token]
      token_filter.error = options[:error_token] if options[:error_token]
      
      state_formater = ParseStateFormater.new(STDOUT, state_filter)
      token_count_formater = TokenCounterFormater.new(STDOUT, token_filter)
      
      idx_states, idx_tokens = Saikuro.analyze(
        files_in_dirs(options[:code_dirs]),
        state_formater,
        token_count_formater,
        options[:output_directory]
      )
      
      write_cyclo_index(idx_states, options[:output_directory])
      write_token_index(idx_tokens, options[:output_directory])
    end
    
    def files_in_dirs(code_dirs)
      code_dirs = [code_dirs].flatten
      code_dirs.collect {|dir| Dir["#{dir}/**/*.rb"]}.flatten
    end
    
  end
  

  DEFAULT_CONFIG = {
    :code_dirs => ['app/controllers', 'app/models', 'app/helpers', 'lib'],
    :output_file => 'reports/saikuro_treemap.html',
    :warn_cyclo => 5,
    :error_cyclo => 7,
    :filter_cyclo => 0
  }
  
  def self.generate_treemap(config={})
    temp_dir = 'tmp/saikuro'
    
    config = DEFAULT_CONFIG.merge(config)
    
    config[:output_directory] = temp_dir

    SaikuroRake.new.run(config)
    
    saikuro_files = Parser.parse(temp_dir)
    
    @ccn_node = create_ccn_root_node(saikuro_files)    
    FileUtils.mkdir_p(File.dirname(config[:output_file]))

    File.open(config[:output_file], 'w') do |f|
      f << ERB.new(File.read(template('saikuro.html.erb'))).result(binding)
    end
  end
  
  def self.create_ccn_root_node(saikuro_files)
    root_node = CCNNode.new('')
    saikuro_files.each do |f|      
      f[:classes].each do |c|
        class_node_name = c[:class_name]
        namespaces = class_node_name.split("::")[0..-2]
        root_node.create_nodes(*namespaces)
        parent = root_node.find_node(*namespaces)
        class_node = CCNNode.new(class_node_name, c[:complexity], c[:lines])
        parent.add_child(class_node)

        c[:methods].each do |m|
          class_node.add_child(CCNNode.new(m[:name], m[:complexity], m[:lines]))
        end
      end
    end

    root_node
  end
    
  def self.template(file)
    File.expand_path("../../templates/#{file}", __FILE__)
  end

end

