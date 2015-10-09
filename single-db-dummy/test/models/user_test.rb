    require 'test_helper'

    class UserTest < ActiveSupport::TestCase
      test "should save" do
        user = User.new
        assert user.save
      end
    end
