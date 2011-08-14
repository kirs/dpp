class Admin < ActiveRecord::Base
  validates :username, :password, :presence => true
end