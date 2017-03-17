class Cat < SQLObject
  belongs_to :human, :foreign_key => :owner_id
  # `Human` class not defined yet!
  has_one_through :house, :human, :house

  finalize!
end
