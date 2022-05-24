require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'formatador'

class ZDFTeletext
  # TODO add possibility to only retrieve a single page
  def cleanup_body(html)
    html.css("head").remove
    html.css("div.breadcrumbs").remove
    html.css("div#footer_container").remove
    return html.css("body")
  end

  def check_table(html) # TODO maybe replace with "check_menu_table"?
    if html.at_css("table")
      true
    else
      false
    end
  end

  # used to parse menus
  def parse_table(html)
    if check_table(html)
      rows = Array.new
      html.search('table').each do |table|
        table.search('tr').each do |tr|
          cells = tr.search('th, td')
          rows.push({:Seite => cells[0].text.strip, :Nummer => cells[1].text.strip})
        end
      end
      Formatador.display_table(rows)
    end
  end

  def teletext_request(number)
    #make request
    url = "https://teletext.zdf.de/teletext/zdf/seiten/"+number+".html"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri) # TODO add Timeout
    if(response.code == "200")
      html = Nokogiri::HTML(response.body)
      @current_page=number
      # TODO set @next_page and @previous_page by the attributes in the <body> tag
      @next_page=html.css("body").map{ |body| body.attribute('next_page')}
      @previous_page=html.css("body").map{ |body| body.attribute('previous_page')}
      teletext_print_response(html)
    else
      raise StandardError.new "Something went wrong trying to fetch the given page"
    end
  end

  def teletext_print_response(html)
    body = cleanup_body(html)
    if check_table(body)
      puts parse_table(body) 
    else
      puts body.text.gsub(/\n(\s*\n)+/,"\n").gsub(/\t+/, "")
    end
  end

  def previous_page
    teletext_request(@previous_page)
  end

  def next_page
    teletext_request(@next_page)
  end

  def run()
    # TODO add Date and Time to header
    puts "ZDF-Teletext\n"
    teletext_request('100')

    while true do
      puts "Seite, q zum Beenden: " # TODO add next/previous pages
      input = gets.chomp
      
      system "clear"
      puts "ZDF-Teletext\n"

      case input
        when "q"
          break
        when "p"
          previous_page
        when "n"
          next_page
        else # TODO durch case mit -INFINITY...INFINITY ersetzen
          begin
            teletext_request(input)
          rescue Exception => ex
            puts ex.message
          end
      end
    end
  end
end

teletext = ZDFTeletext.new
teletext.run