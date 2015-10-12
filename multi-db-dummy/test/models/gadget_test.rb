    require 'test_helper'

    class GadgetTest < ActiveSupport::TestCase
      test "should save" do
        gadget = Gadget.new
        assert gadget.save
      end
    end
