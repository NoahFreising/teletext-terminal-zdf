require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'formatador'

def cleanup_body(html)
  html.css("head").remove
  html.css("div.breadcrumbs").remove
  html.css("div#footer_container").remove
  return html.css("body")
end

def check_table(html)
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
  response = Net::HTTP.get_response(uri)
  if(response.code == "200")
    teletext_print_response(response)
  else
    raise StandardError.new "Something went wrong trying to fetch the given page"
  end
end

def teletext_print_response(response)
  #parse html
  html = Nokogiri::HTML(response.body)
  body = cleanup_body(html)
  if check_table(body)
    puts parse_table(body) 
  else
    puts body.text.gsub(/\n(\s*\n)+/,"\n").gsub(/\t+/, "")
  end
end


puts "ZDF-Teletext\n"
teletext_request('100')

while true do
  puts "Seite, q zum Beenden: "
  input = gets.chomp
  
  system "clear"
  puts "ZDF-Teletext\n"

  break if input == "q"

  begin
    teletext_request(input)
  rescue Exception => ex
    puts ex.message
  end
end
