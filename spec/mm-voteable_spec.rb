require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoMapper::Plugins::Voteable" do
  
  before(:each) do
    @user = User.create(:email => 'luke@icaruswings.com')
    @user_2 = User.create(:email => 'lukec@icaruswings.com')
    @voteable = VoteableWithCallback.create(:user_id => User.create().id)
  end

  it "should be voteable" do
    @voteable.should be_voteable
  end

  it "should have a votes_count attribute that defaults to 0" do
     @voteable.votes_count.should equal 0
  end

  describe "add_vote!" do
  
    it "should increment the votes_count attribute" do
      lambda {
        @voteable.add_vote!(1, @user)
      }.should change(@voteable, :votes_count).by(1)
    end
  
    it "should add the vote" do
      @voteable.add_vote!(1, @user)
    
      # @voteable.should have(1).vote
      @voteable.votes_count.should equal 1
    end
    
    it "should add a second vote" do
      @voteable.add_vote!(1, @user)
      @voteable.add_vote!(1, @user_2)
    
      # @voteable.should have(2).votes
      @voteable.votes_count.should equal 2
    end
    
    it "should assign the voter" do
      @voteable.add_vote!(1, @user) 
      vote = @voteable.votes.first
      
      vote.voter.should == @user
    end

    # it "should throw NotImplementedError if the :on_add_vote callback has not inplemented" do
    #   commentable = CommentableWithoutCallback.new
    #   lambda {
    #     commentable.add_comment!(1, @luke)
    #   }.should raise_error(NotImplementedError)
    # end

    # it "should call :on_add_vote if the callback has been implemented" do
    #   @commentable.should_receive(:on_add_comment)
    #   @commentable.add_comment!(1, @luke)
    # end
  
  end
  
end

# describe "Vote" do
#   
#   before(:each) do
#     @comment = Comment.new
#   end
#   
#   it "should be embeddable?" do
#     Comment.embeddable?.should be_true
#   end
#   
#   it "should be embeddable?" do
#     Comment.embeddable?.should be_true
#   end
#   
#   it "should have a created_at key" do
#     @comment.should respond_to(:created_at=)
#     @comment.should respond_to(:created_at)
#   end
#   
#   it "should have a commentor association" do
#     @comment.should respond_to(:commentor_id=)
#     @comment.should respond_to(:commentor_id)
#     @comment.should respond_to(:commentor_type=)
#     @comment.should respond_to(:commentor_type)
#     
#     @comment.commentor.association.should be_belongs_to
#   end
#   
# end