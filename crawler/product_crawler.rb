class ProductCrawler
  attr_accessor :url, :urls, :results, :database

  def initialize(root: '', db: database)
    @url      = root
    @results  = []
    @urls     = {}
    @database = db
  end

  def fetch_products
    return unless processed?(url)

    page = agent.get(url)
    data, links = Product.new(page).process_page

    save_product(data)
    links.each do |link|
      @url = link
      next unless fetch_products
    end
  end

  def print_products
    all_products.each do |product|
      puts "Name: #{product['name']}\n"\
           "Price: #{product['price']}\n"\
           "Description: #{product['description']}\n"\
           "Extra information: #{product['extra_info']}\n\n"
    end
    puts "Number of products newly processed: #{results.count}"
    puts "Total number of products: #{all_products.count}"
  end

  private

  def agent
    @agent ||= Mechanize.new
  end

  def processed?(url)
    return if urls[url]

    urls[url] ||= true
  end

  def save_product(data = {})
    return if find_existing?(data[:url])

    database.execute 'INSERT INTO products (name, price, description, extra_info, url)'\
                      'VALUES (?, ?, ?, ?, ?)', data[:name], data[:price], data[:description], data[:extra_info], data[:url]

    results << data
  end

  def all_products
    database.execute 'select * from products'
  end

  def find_existing?(url)
    database.execute('select * from products where url=?', url).length.positive?
  end
end
