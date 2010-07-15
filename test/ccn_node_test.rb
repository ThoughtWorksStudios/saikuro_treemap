require 'test_helper'

class CCNNodeTest < Test::Unit::TestCase
  include SaikuroTreemap
  
  def test_to_json_for_single_node
    assert_equal '{"name":"A","id":"A","children":[]}', CCNNode.new('A', 'A').to_json
  end
  
  def test_to_json_for_node_with_children
    root = CCNNode.new('A', 'A')
    root.add_child CCNNode.new('A::B', 'B')
    assert_equal '{"name":"A","id":"A","children":[{"name":"B","id":"A::B","children":[]}]}', root.to_json
  end
end