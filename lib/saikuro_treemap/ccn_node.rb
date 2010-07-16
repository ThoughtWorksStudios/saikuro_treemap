module SaikuroTreemap
  class CCNNode
    attr_reader :path
    
    def initialize(path, attributes = {})
      @path = path
      @attributes = attributes
      @children = []
    end

    def add_child(child)
      @children << child
    end

    def find_node(*pathes)
      return self if pathes.join("::") == @path
      return self if pathes.empty?

      # Eumerable#find is buggy!
      @children.each do |child|
        if r = child.find_node(pathes)
          return r 
        end
      end
      return nil
    end

    def create_nodes(*pathes)
      pathes.each_with_index {|_, i| find_or_create_node(*pathes[0..i]) }
    end
    
    def to_json(*args)
      @attributes.merge({'name' => compact_name, 'id' => @path, 'children' => @children}).to_json(*args)
    end
    
    private
    
    def compact_name
      return '' if @path !~ /\S/
      @path.split('::').last.split('#').last
    end
    
    def find_or_create_node(*pathes)
      find_node(*pathes) || create_node(*pathes)
    end
    
    def create_node(*pathes)
      parent = find_node(*pathes[0..-2])
      parent.add_child(CCNNode.new(pathes.join("::")))
    end
  end
end