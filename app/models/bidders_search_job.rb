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
    count = all_table_nodes.at_css('.text12 .white b').text.scan(/\d+/).join.to_i
    { :list => list, :count => count }
  end

  def self.extract_row node
    nodes = node.css('td')
    {
      :img => nodes[0].at_css('img')['src'],
      :title => nodes[3].at_css('a').text,
      :url => 'http://www.bidders.co.jp' + nodes[3].at_css('a')[:href],
      :seller => nodes[3].children[0].children[1].text,
      :price => nodes[6].at_css('b').text,
      :bid => nodes[8].text,
      :time => nodes[10].text
    }
  end
end
