require_relative 'crawler/product_crawler'
require_relative 'product'
require 'mechanize'
require 'pry'
require 'sqlite3'

begin
  db = SQLite3::Database.open 'finology.db'
  db.results_as_hash = true
  db.execute 'CREATE TABLE IF NOT EXISTS products(name TEXT, price TEXT,'\
             'description TEXT, extra_info TEXT, url TEXT)'

  crawler = ProductCrawler.new(root: 'http://magento-test.finology.com.my/breathe-easy-tank.html', db: db)
  crawler.fetch_products
  crawler.print_products
rescue SQLite3::Exception => e
  puts e
ensure
  # If the whole application is going to exit and you don't
  # need the database at all any more, ensure db is closed.
  # Otherwise database closing might be handled elsewhere.
  db&.close
end
