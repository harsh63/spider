class Product
  attr_reader :page

  def initialize(page)
    @page = page
  end

  def process_page
    data = {
      name: page.at('meta[property="og:title"]')[:content],
      price: page.at('.product-info-price .price').text,
      description: page.at('.product.attribute.description').text.strip.delete("\n"),
      extra_info: page.search('#product-attribute-specs-table tbody tr').map do |tr|
        "#{tr.elements.first.text}: #{tr.elements.last.text}"
      end.join(' | '),
      url: page.uri.to_s
    }

    links = page.search('.product-item-link').map { |link| link.attributes['href'].value }

    [data, links]
  end
end
