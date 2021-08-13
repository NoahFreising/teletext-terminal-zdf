require 'open-uri'
require 'net/http'
require 'nokogiri'

while true do
  puts "ZDF-Teletext"
  puts "================================"
  puts "Seite (z.B. 100), q zum Beenden: "
  input = gets.chomp

  if input == "q"
    break
  end

  #make request
  url = "https://teletext.zdf.de/teletext/zdf/seiten/"+input+".html"
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)

  if response.code == "200"
    #parse html
    html = Nokogiri::HTML(response.body)

    html.css("head").remove
    html.css("div.breadcrumbs").remove
    html.css("div#footer_container").remove

    puts html.css("body").text.gsub(/\n(\s*\n)+/,"\n").gsub(/\t+/, "")
  else
    puts "Die Seite(=#{seite}) konnte nicht geladen werden."
  end
end