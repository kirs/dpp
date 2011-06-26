class RequestLog < ActiveRecord::Base
  validates :from, :to, :ip, :presence => true
end
