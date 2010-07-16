require 'test_helper'

class CCNNodeTest < Test::Unit::TestCase
  include SaikuroTreemap
  
  def test_to_json_for_single_node
    assert_equal '{"name":"A","id":"A","children":[]}', CCNNode.new('A').to_json
  end
  
  def test_to_json_for_node_with_children
    root = CCNNode.new('A')
    root.add_child CCNNode.new('A::B')
    assert_equal '{"name":"A","id":"A","children":[{"name":"B","id":"A::B","children":[]}]}', root.to_json
  end
  
  def test_to_json_for_method_node
    assert_equal '{"name":"abc","id":"A#abc","children":[]}', CCNNode.new('A#abc').to_json  
  end
  
  def test_to_json_for_root_node
    assert_equal '{"name":"","id":"","children":[]}', CCNNode.new('').to_json  
  end
  
  def test_find_node_without_param_should_return_it_self
    node = CCNNode.new('A::B::C')
    assert_equal node, node.find_node()
  end
  
  def test_find_node_should_find_it_self_it_path_match
    node = CCNNode.new('A::B::C')
    assert_equal node, node.find_node('A', 'B', 'C')
    assert_equal nil, node.find_node('A', 'B')
  end
  
  def test_find_node_should_find_matching_child_node
    parent = CCNNode.new('A')
    child = CCNNode.new('A::B::C')
    parent.add_child child
    
    assert_equal child, parent.find_node('A', 'B', 'C')
    assert_equal nil, parent.find_node('A', 'B')
  end
  
  def test_create_nodes
    node = CCNNode.new('A')
    node.create_nodes('A', 'B', 'C', 'D')
    
    assert_equal 'A::B', node.find_node('A', 'B').path
    assert_equal 'A::B::C', node.find_node('A', 'B', 'C').path
    assert_equal 'A::B::C::D', node.find_node('A', 'B', 'C', 'D').path
  end
  
  
  
end