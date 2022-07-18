require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'formatador'

##
# Class for accessing the ZDF Teletext
class ZDFTeletext

  ##
  # Print a single page from the Teletext
  def print_page(number)
    teletext_request(number)
  end

  ##
  # Runs the tool interactively, allowing easy browsing
  def interactive_run()
    # TODO add Date and Time to header
    puts "ZDF-Teletext\n"
    teletext_request('100')

    while true do
      puts "\t#{@previous_page} <-\t\t#{@current_page}\t\t -> #{@next_page}"
      puts "Seite, (q)uit, (n)ext page, (p)revious page: " # TODO add next/previous pages
      input = gets.chomp
      
      system "clear"
      puts "ZDF-Teletext\n"
      begin
        case input
          when "q"
            break
          when "p"
            previous_page
          when "n"
            next_page
          else
            teletext_request(input)
        end
      rescue Exception => ex
        puts ex.message
        puts "Please enter a valid page, e.g. 100"
      end
    end
  end

  private

  ##
  # Removes unneccessary code from the html response
  def cleanup_body(html)
    html.css("head").remove
    html.css("div.breadcrumbs").remove
    html.css("div#footer_container").remove
    return html.css("body")
  end

  ##
  # Checks if the html contains an overview table
  def check_overview_table(html)
    if html.at_css("table.link_button") 
      true
    else
      false
    end
  end

  def extract_rows_from_table(html)
    rows = Array.new
    html.search('table').each do |table|
      table.search('tr').each do |tr|
        cells = tr.search('th, td')
        rows.push({:Seite => cells[0].text.strip, :Nummer => cells[1].text.strip})
      end
    end
    return rows
  end

  ##
  # Checks html for tables and prints them using formatador 
  def parse_table(html)
    if check_overview_table(html)
      rows = extract_rows_from_table(html)
      Formatador.display_table(rows)
    end
  end

  ##
  # Makes a request to a given teletext site,
  # sets instance variables and initiates printing
  def teletext_request(number)
    #make request
    url = "https://teletext.zdf.de/teletext/zdf/seiten/#{number}.html"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri) # TODO add Timeout
    if(response.code == "200")
      html = Nokogiri::HTML(response.body)

      @current_page=html.css("body").attribute('page').value
      @next_page=html.css("body").attribute('nextpg').value
      @previous_page=html.at_css("body").attribute('prevpg').value

      teletext_print_response(html)
    else
      raise StandardError.new "Something went wrong trying to fetch the given page"
    end
  end

  ##
  # Prints the formatted Teletext to terminal
  def teletext_print_response(html)
    body = cleanup_body(html)
    if check_overview_table(body)
      puts parse_table(body) 
    else
      puts body.text.gsub(/\n(\s*\n)+/,"\n").gsub(/\t+/, "")
    end
  end

  ##
  # Opens the previous page
  def previous_page
    teletext_request(@previous_page)
  end

  ##
  # Opens the next page
  def next_page
    teletext_request(@next_page)
  end
end

teletext = ZDFTeletext.new

if ARGV.length == 1
  teletext.print_page(ARGV[0])
elsif ARGV.length == 0
  teletext.interactive_run
else
  raise StandardError.new("Usage: ruby zdf_teletext.rb [page no.]")
end