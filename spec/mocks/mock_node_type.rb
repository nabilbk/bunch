# encoding: UTF-8

module Bunch
  define_mock :node_type do
    stubs :matches?,
      params: [instance_of(FileTree), responds_to(:to_str)],
      returns: false
  end
end

describe "#mock_node_type" do
  subject { mock_node_type }
  it_behaves_like :node_type
end
