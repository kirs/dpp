class Request < ActiveRecord::Base
  validates :from, :to, :presence => true
  validates_numericality_of :transfers_number
  validates_inclusion_of :transfers_number, :in => 1..7
end
