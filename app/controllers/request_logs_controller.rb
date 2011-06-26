class RequestLogsController < ApplicationController
  before_filter :admin_required
  
  def index
    @request_logs = RequestLog.order('created_at DESC')
  end
end
