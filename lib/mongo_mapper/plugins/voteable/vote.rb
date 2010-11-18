class Vote
  include MongoMapper::EmbeddedDocument
  
  embedded_in :voteable
  
  key :voter_id, ObjectId, :required => true
  belongs_to :voter, :class_name => 'User'

  key :value, Integer, :required => true

  # key :voteable_id, ObjectId, :required => true
  # key :voteable_type, String, :required => true
  # belongs_to :voteable, :polymorphic => true

  validates_inclusion_of :value, :within => [1,-1]

  validate [:should_be_unique, :should_not_be_owner]

  def should_be_unique
    vote = voteable.votes({
      :voteable_type => self.voteable_type,
      :voteable_id => self.voteable_id,
      :voter_id => self.voter_id
    })
    valid = vote.nil?
    return true if valid
    self.errors.add(:voter, "You already voted this #{self.voteable_type}.")
    return false
  end
  
  def should_not_be_owner
    return true unless self.voteable.user_id == self.voter_id
    self.errors.add(:vote, "You cant vote on this #{self.voteable_type}.")
    return false
  end
  
end