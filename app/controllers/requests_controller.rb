class RequestsController < ApplicationController

  def index
    @request = Request.new
    render :index
  end

  def find
    @request = Request.new(params[:request])
    if @request.valid?
      @from = @request.from
      @to = @request.to
      @via = @request.via
      client_ip = request.env["HTTP_X_FORWARDED_FOR"]
      client_ip ||= request.remote_ip
      # logging
      RequestLog.create(:from => @from, :to => @to, :route_at => @request.route_at, :ip => client_ip)
      
      agent = Mechanize.new 
      page = agent.get("http://www.dpp.cz/")
      form = page.form_with(:action => 'http://idos.dpp.cz/idos/ConnForm.aspx')
      form['f'] = @from
      form['t'] = @to
      form['v'] = @via
      form['date'] = @request.route_at.strftime("%d.%m.%Y")
      form['time'] = @request.route_at.strftime("%H:%M")
        
      unless @request.is_departure_time
        form.radiobuttons_with(:name => 'isdep')[1].check
      end
      # Transfers
      unless @request.with_transfers # without transfers
        form.radiobuttons_with(:name => 'alg')[0].check
      else # set, how many
        form.field_with(:name => 'chn').options[@request.transfers_number-1].select
      end
      page = agent.submit form
      @trips = []
      # Parsing response
      page.parser.css('#pole .spojeni').each do |link|
        info = Array.new
        title = link.css("h3").text.gsub(t('.from_to'), t('.dash')).strip.delete_nbsp
        # Clearing title
        info.push title
        info.push []
        link.css('p').each do |direction|
          # parsing direction
          type = direction.attribute('class').text
          unless type.strip == 'note'
            tip = direction.text.delete_nbsp.strip
            # Clearing direction text
            tip.gsub!('. .', '')
            tip.gsub!(' , ', ', ')
            info.last.push tip
          end
        end
        @trips.push info
      end
      if @trips.length.zero?
        flash[:notice] = t('.not_found')
        render :index and return
      end
      render :find and return
    else
      flash[:notice] = t('.empty_fields')
      render :index
    end
  end
end

