# encoding: utf-8

require "spec_helper"

module Bunch
  describe Nodes::File do
    subject { Nodes::File }
    it_behaves_like :node_type

    describe ".matches?" do
      it "always matches" do
        subject.matches?(mock).must_equal true
      end
    end
  end
end
