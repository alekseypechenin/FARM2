class Field < ActiveRecord::Base
  validates :ftype,  :presence => true
  validates :fstate, :presence => true
  validates :x, :presence => true
  validates :y, :presence => true

  belongs_to :user
end
