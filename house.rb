class House < SQLObject
  has_many :humans, foreign_key: :house_id

  has_many_through :cats, :humans, :cats

  finalize!
end

# load 'house.rb'
# load 'cat.rb'
# load 'human.rb'
# House.find(1).cats
