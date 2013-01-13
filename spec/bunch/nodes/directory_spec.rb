# encoding: utf-8

require "spec_helper"

module Bunch
  describe Nodes::Directory do
    subject { Nodes::Directory }
    it_behaves_like :node_type

    describe ".matches?" do
      it "is true if the path is a directory" do
        path = stub(:directory? => true)
        subject.matches?(path).must_equal true
      end

      it "is false if the path is not a directory" do
        path = stub(:directory? => false)
        subject.matches?(path).must_equal false
      end
    end
  end
end
