class Menu < ApplicationRecord
  belongs_to :parent, class_name: 'Menu', optional: true

  has_many :children, class_name: 'Menu', foreign_key: 'parent_id'

  validates_presence_of :label, :users_allowed
end
