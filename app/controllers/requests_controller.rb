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
      @log = RequestLog.create(:from => @from, :to => @to, :route_at => @request.route_at, :ip => client_ip)
      
      agent = Mechanize.new 
      page = agent.get("http://www.dpp.cz/")
      form = page.form_with(:action => 'http://idos.dpp.cz/idos/ConnForm.aspx')
      form['f'] = @from
      form['t'] = @to
      form['v'] = @via
      form['date'] = @request.route_at.strftime("%d.%m.%Y")
      form['time'] = @request.route_at.strftime("%H:%M")
        
      if !@request.is_departure_time
        form.radiobuttons_with(:name => 'isdep')[1].check
      end
      # Transfers
      if(! @request.with_transfers) # without transfers
        form.radiobuttons_with(:name => 'alg')[0].check
      else # set, how many
        form.field_with(:name => 'chn').options[@request.transfers_number-1].select
      end
      page = agent.submit form
      @trips = Array.new
      # Parsing response
      page.parser.css('#pole .spojeni').each do |link|
        info = Array.new
        title = link.css("h3").text.gsub(t('.from_to'), t('.dash')).strip.mb_chars
        # Clearing title
        title.gsub!('  ', ' ')
        info.push(title)
        info.push(Array.new)
        link.css('p').each do |direction|
          # parsing direction
          type = direction.attribute('class').text
          if(type.strip != 'note')
            clear_text = direction.text.mb_chars
            # Clearing direction text
            clear_text.gsub!('. .', '')
            clear_text.gsub!(' , ', ', ')
            clear_text.gsub!('  ', ' ')
            clear_text.gsub(/\b\d{1,2}:\d{2}\b/, '<b>\0</b>')
            # clear_text = clear_text.gsub(/\d{1,2}:\d{2}/).each {|hour| hour = "<i>#{hour}</i>" }
            clear_text.gsub!("\n", ' ')
            info.last.push(clear_text.strip);
          end
        end
        @trips.push(info)
      end
      if(@trips.length < 1)
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

