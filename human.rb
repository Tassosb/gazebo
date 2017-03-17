class Human < SQLObject
  has_many :cats, :foreign_key => :owner_id

  belongs_to :house, :foreign_key => :house_id

  finalize!
end
