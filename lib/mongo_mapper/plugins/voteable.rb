require File.join(File.dirname(__FILE__), 'voteable', 'vote')

module MongoMapper
  module Plugins
    module Voteable

      def self.configure(model)
        model.class_eval do
          key :votes_count, Integer, :default => 0
          key :votes_average, Integer, :default => 0
          key :voter_ids, Array, :typecast => 'ObjectId'
        
          many :votes, :as => 'voteable', :dependent => :destroy

          def voteable?; true; end
        end
      end

      module InstanceMethods
      
        def add_vote!(vote_value, voter)
          vote = self.votes.build(:value => vote_value, :voter => voter)

          return false unless vote.valid?
          vote.save
          
          self.class.push_uniq(self.id, 'voter_ids' => voter.id)
          self.increment('votes_count' => 1, 'votes_average' => vote_value.to_i)
          
          on_add_vote(vote)
        end

        def on_add_vote(vote)
          raise NotImplementedError
        end
      
        def voters
          User.find(self.voter_ids)
        end

      end

      module ClassMethods
      end

    end
  end
end