require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup 
    @user = users(:dylan)
    @micropost = @user.microposts.build(content: "Lorem Ipsum")
  end
  
  test "should be valid" do
    assert @micropost.valid?
  end
  
  test "should have user id" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  test "should have content" do
    @micropost.content = "    "
    assert_not @micropost.valid?
  end
  
  test "content should not be more than 140 chars" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
  
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
  
end
