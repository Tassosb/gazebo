class Cat < SQLObject
  validates :name, presence: true, uniqueness: true
  validates :owner_id, presence: true, uniqueness: true

  belongs_to :human, :foreign_key => :owner_id

  has_one_through :house, :human, :house

  finalize!
end
