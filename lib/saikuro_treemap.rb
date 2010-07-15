require 'rubygems'
require 'json'

require 'saikuro_treemap/parser'
require 'saikuro_treemap/ccn_node'

module SaikuroTreemap
  
  DEFAULT_CONFIG = {
    :code_dirs => ['app/controllers', 'app/models', 'app/helpers' 'lib'],
    :output_file => 'reports/saikuro_treemap.html',
    :saikuro_args => [
      "--warn_cyclo 5",
      "--error_cyclo 7",
      "--formater text",
      "--cyclo --filter_cyclo 0"]
  }
  
  def self.generate_treemap(config={})
    require 'erb'
    
    temp_dir = 'tmp/saikuro'
    
    config = DEFAULT_CONFIG.merge(config)
    
    config[:saikuro_args] << "--output_directory #{temp_dir}"
    
    options_string = config[:saikuro_args] + config[:code_dirs].collect { |dir|  "--input_directory '#{dir}'" }
    
    
    rm_rf temp_dir
    sh %{saikuro #{options_string.join(' ')}} do |ok, response| 
      unless ok 
        puts "Saikuro failed with exit status: #{response.exitstatus}" 
        exit 1 
      end 
    end
    
    saikuro = Parser.parse(temp_dir)
    puts "[DEBUG] saikuro => #{saikuro.inspect}"
    
    @ccn_node = create_ccn_root_node(saikuro)
    puts "[DEBUG] @ccn_node => #{@ccn_node.inspect}"
    
    FileUtils.mkdir_p(File.dirname(config[:output_file]))

    File.open(config[:output_file], 'w') do |f|
      f << ERB.new(File.read(template('saikuro.html.erb'))).result(binding)
    end
  end
  
  def self.create_ccn_root_node(saikuro)
    root_node = CCNNode.new('', '', :data => {})
    saikuro.each {|f|
      puts "[DEBUG] f => #{f.inspect}"
      
      f[:classes].each do |c|
        class_node_name = c[:class_name]
        namespaces = class_node_name.split("::")[0..-2]
        namespaces.each_with_index do |name, i|
          root_node.find_or_create_node(namespaces[0..i])
        end    

        class_node = CCNNode.new(class_node_name, class_node_name.split("::").last, :data => {:complexity => c[:complexity], :lines => c[:lines], :$area => c[:lines], :$color => '#101010'})

        parent = (root_node.find_node(class_node_name.split("::")[0..-2]) || root_node)
        parent.add_child(class_node)

        c[:methods].each do |m|
          method_node_name = m[:name]
          method_node = CCNNode.new(method_node_name, method_node_name.split('#').last, :data => {:complexity => m[:complexity], :lines => m[:lines], :$area => m[:lines], :$color => ccn_color(m[:complexity])})
          class_node.add_child(method_node)
        end
      end
    }

    root_node
  end
  
  def self.ccn_color(ccn)
    return "#AE0000" if ccn > 10
    return "#006500" if ccn <= 5
    return "#4545C2"
  end
  
  def self.template(file)
    File.expand_path("../../templates/#{file}", __FILE__)
  end

end

