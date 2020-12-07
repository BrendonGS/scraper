require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper
  url = "https://www.monster.com/jobs/search/?where=Chicago__2C-IL&intcid=skr_navigation_nhpso_searchMain"
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)
  jobs = Array.new
  job_listings = parsed_page.css('div.summary') #26 jobs

  page = 1
  per_page = job_listings.count #currently 26 but now dynamic
  total = parsed_page.css('h2.figure').text.split(' ')[0].gsub('(','').to_i #39890
  last_page = (total.to_f / per_page.to_f).round

  while page <= last_page
    pagination_url = "https://www.monster.com/jobs/search/?where=Chicago__2C-IL&intcid=skr_navigation_nhpso_searchMain&stpage=#{page}"
    puts pagination_url
    puts "Page: #{page}"
    puts ''
    pagination_unparsed_page = HTTParty.get(pagination_url)
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
    pagination_job_listings = pagination_parsed_page.css('div.summary') #26 jobs

    pagination_job_listings.each do |job_listing|
      job = {
        title: job_listing.css('h2.title').text,
        company: job_listing.css('div.company').text,
        location: job_listing.css('div.location').text,
        url: job_listing.css('a')[0].attributes["href"].value
      }
      jobs << job
      puts "Added #{job[:title]}"
      puts "" 
    end
    page += 1
  end
  byebug
end

scraper