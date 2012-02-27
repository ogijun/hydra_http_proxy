class BiddersSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => bidders_url, :filter => 'bidders_search')
  end

  def bidders_url
    opt = params['options']
    search_keyword_e_sjis = opt['q']
    minprice = nil
    maxprice = nil
    page = opt['page']
    base = 'http://www.bidders.co.jp/dap/sv/list1'
     "#{base}?ut=&sort=#{sort_option_bidders}&categ_id=#{opt['c']}&cf=N&srm=Y&spec_keyword=#{search_keyword_e_sjis}&clow=#{minprice}&chigh=#{maxprice}&at=NO%2CPA%2CFL&page=#{page}"
  end

  def sort_option_bidders
    "sort=end,A"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::HTML(body)
    all_table_nodes = doc.css('table')
    list_nodes = all_table_nodes.find { |node| node.css('table').length == 40 }
    list = list_nodes.children[3, 80].each_slice(2).map { |node, dum| extract_row node }
    count = nil
    { :list => list, :count => count }
  end

  def self.extract_row node
    node.text
    # {
    #   :text => node[0].text,
    #   :url => node[1].text,
    #   :seller => node.css('a')[2].text,
    #   :price => node.at_css('.li_price').text,
    #   :bid => node.at_css('.li_bid').text,
    #   :time => node.at_css('.li_time').text,
    #   :bid => node.at_css('.li_bid').text,
    #   :img => node.at_css('.imgbox img')['src'],
    # }
  end
end
