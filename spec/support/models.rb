class VoteableWithCallback
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Voteable  
  
  key :user_id, ObjectId
  
  def on_add_vote(vote)
    reload
  end
end

class VoteableWithoutCallback
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Voteable  
end

class User
  include MongoMapper::Document
  key :email, String
end