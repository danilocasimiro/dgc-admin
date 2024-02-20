class Menu < ApplicationRecord
  belongs_to :parent, class_name: "Menu", optional: true

  has_many :child, class_name: "Menu", foreign_key: "parent_id"
end
