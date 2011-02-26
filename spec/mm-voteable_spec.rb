require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Vote" do
  
  before(:each) do
    @user = User.create(:email => 'luke@icaruswings.com')
    @voteable = VoteableWithCallback.create(:user_id => User.create().id)
    @vote = @voteable.votes.build(:value => 1, :voter => @user)
  end
  
  it "should not be embedded?" do
    Vote.embeddable?.should_not be_true
  end
  
  
  it "should be valid" do
    @vote.should be_valid
  end
  
  it "should not be valid if already voted" do
    @vote.save
    vote = @voteable.votes.build(:value => 1, :voter => @user)
    
    vote.should_not be_valid
  end
  
  it "should not be valid value is not one of 1 or -1" do
    @vote.value = 3

    @vote.should_not be_valid
  end
  
  it "should not be valid if voteable owner" do
    voteable = VoteableWithCallback.create(:user_id => @user.id)
    vote = voteable.votes.build(:value => 1, :voter => @user)
    
    vote.should_not be_valid
  end
  
  it "should have a belongs_to voteable association" do
    @vote.voteable.association.should be_belongs_to
    @vote.voteable.should == @voteable
  end
  
  it "should have an associated voter" do
    @vote.voter.association.should be_belongs_to
    @vote.voter.should == @user
  end

end

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
      
      lambda {
        @voteable.add_vote!(1, User.create(:email => 'lukec@icaruswings.com'))
      }.should change(@voteable, :votes_count).by(1)
      
      @voteable.votes_count.should equal 2
    end
  
    it "should add the vote" do
      @voteable.add_vote!(1, @user)
    
      @voteable.should have(1).vote
      @voteable.votes.count.should equal 1
      @voteable.votes_count.should equal 1
    end
    
    it "should add a second vote" do
      @voteable.add_vote!(1, @user)
      @voteable.add_vote!(-1, @user_2)

      @voteable.should have(2).votes
      @voteable.votes.count.should equal 2
      @voteable.votes_count.should equal 2
    end
    
    it "should assign the voter" do
      @voteable.add_vote!(1, @user) 
      vote = @voteable.votes.first
      
      vote.voter.should == @user
    end
    
    it "should have a way of retrieving all voters on voteable" do
      @voteable.add_vote!(1, @user) 

      @voteable.voters.should include(@user)
    end

    it "should throw NotImplementedError if the :on_add_vote callback has not inplemented" do
      voteable = VoteableWithoutCallback.new
      lambda {
        voteable.add_vote!(1, @user)
      }.should raise_error(NotImplementedError)
    end

    it "should call :on_add_vote if the callback has been implemented" do
      @voteable.should_receive(:on_add_vote)
      @voteable.add_vote!(1, @user)
    end
  
  end
  
end