require 'spec_helper'

describe Micropost do
  
  let(:user) { FactoryGirl.create(:user) }
  # before do
  #   # This code is not idiomatically correct. Notice that the micropost belongs to no one.
  #   @micropost = Micropost.new(content: "Lorem ipsum", user_id: user.id)
  # end

  # The correct before block would be:
  before { @micropost = user.microposts.build(content: "Lorem ipsum") }

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should eq user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @micropost.user_id = nil}
    it { should_not be_valid }
  end
end