module SaikuroTreemap
  class CCNNode
    def initialize(id, name, attributes = {})
      @name = name
      @id = id
      @attributes = attributes
      @children = []
    end

    def add_child(child)
      @children << child
    end

    def find_node(path)
      return self if path.join("::") == @id

      # Eumerable#find is buggy!
      @children.each do |child|
        if r = child.find_node(path)
          return r 
        end
      end
      return nil
    end

    def find_or_create_node(path)
      find_node(path) || create_node(path)
    end

    def create_node(path)
      parent = (path.size == 1) ? self : self.find_node(path[0..-2])
      parent.add_child(CCNNode.new(path.join("::"), path.last))
    end
    
    def to_json(*args)
      @attributes.merge({'name' => @name, 'id' => @id, 'children' => @children}).to_json(*args)
    end
  end
end