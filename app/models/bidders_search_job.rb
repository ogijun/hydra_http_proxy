class BiddersSearchJob < AbstractJob

  def initialize params
    super
    @query_encoding = 'Shift_JIS'
  end

  def morph
    GetApplyJob.new params.merge(:url => bidders_url, :filter => 'bidders_search')
  end

  def bidders_url
    opt = params[:options]
    minprice = nil
    maxprice = nil
    page = opt[:page]
    base = 'http://www.bidders.co.jp/dap/sv/lista1'
    "#{base}?ut=&sort=#{sort}&categ_id=#{category}&cf=N&srm=Y&keyword=#{query}&clow=#{minprice}&chigh=#{maxprice}&at=NO%2CPA%2CFL&page=#{page}"
  end

  def sort
    "sort=end,A"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::HTML(body)
    all_table_nodes = doc.css('table')
    list_nodes = all_table_nodes[18]
    list = list_nodes.children[3, 80].each_slice(2).map { |node, dum| extract_row node }
    count = all_table_nodes.at_css('.text12 .white b').text.scan(/\d+/).join.to_i
    { :list => list, :count => count }
  end

  def self.extract_row node
    nodes = node.css('td')
    {
      :auction_id => nodes[3].at_css('a')[:href].scan(/\d+/).first.to_i,
      :url => 'http://www.bidders.co.jp' + nodes[3].at_css('a')[:href],
      :img => nodes[0].at_css('img')['src'],
      :title => nodes[3].at_css('a').text,
      :seller => nil,
      :price => nodes[6].at_css('b').text,
      :bid => nodes[8].text,
      :end_time => nodes[10].text
    }
  end
end
