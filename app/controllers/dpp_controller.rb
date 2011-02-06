class DppController < ApplicationController
  def index
  	

  end

  def find
  	@query = params[:query]
  	from = @query[:from] != nil ? @query[:from] : 'Dejvicka'
	to = @query[:to] != nil ? @query[:to] : 'Klamovka'
	date = @query[:date] != nil ? @query[:date] : Time.now.localtime.strftime("%d.%m.%Y")
	time = @query[:time] != nil ? @query[:time] : Time.now.strftime("%H:%M")
	isdep = @query[:isdep].to_i

	@trips = Array.new
	
	require 'rubygems'
	require 'mechanize'
	
	agent = Mechanize.new 
	
	page = agent.get("http://www.dpp.cz/")
	login_form = page.form_with(:action => 'http://idos.dpp.cz/idos/ConnForm.aspx')
	login_form['f'] = from
	login_form['t'] = to
	login_form['date'] = date
	login_form['time'] = time
	
	if(isdep == 0)
		login_form.radiobuttons_with(:name => 'isdep')[1].check
	end
	page = agent.submit login_form
	
	#Display welcome message if logged in
	#puts page.parser.xpath("/html/body/div/table/tr/td[2]/div/div").xpath('text()').to_s.strip
	
	#output = File.open("login.html", "w") {|f| f.write(page.parser.to_html) }
	# a - дозаписывать
	
	page.parser.css('#pole .spojeni').each do |link|
		info = Array.new
		title = link.css("h3").text
		info.push(title)
		info.push(Array.new)
		
		link.css('p').each do |direction|
			type = direction.attribute('class').text
			if(type.strip != 'note')
				#info[1].push(direction.text);
				info.last.push(direction.text);
			end
		end
			
		#company["link"] = link.css('.dtl h3 a')[0].attribute('href')
		
		@trips.push(info)
	end
	
  end

end
