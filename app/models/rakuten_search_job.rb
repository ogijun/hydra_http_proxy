class RakutenSearchJob < AbstractJob

  def initialize params
    super
    @query_encoding = 'EUC-JP'
  end

  def morph
    GetApplyJob.new params.merge(:url => rakuten_url, :filter => 'rakuten_search')
  end

  def rakuten_url
    base = "http://esearch.rakuten.co.jp/rms/sd/esearch/vc"
    opt = params[:options]
    page = opt[:page].to_i
    g = 1050000000
    s = 3
    "#{base}?sv=13&f=A&g=#{g}&v=2&e=0&p=#{page}&s=#{s}&oid=000&sub=1&k=0&sf=1&sitem=#{query}&x=0"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::HTML(body)
    list =  doc.xpath("//table[@width='100%'][@border='0'][@cellspacing='1'][@cellpadding='3']").children[1, 30].map { |node| extract_row node }
    count = doc.xpath("//tr[@align='left']/td/font[@size='-1']").map(&:text)[0].split(' ').last.scan(/\d+/).join.to_i
    { :list => list, :count => count }
  end

  def self.extract_row node
    {
      :url => node.at_css('a')['href'],
      :img => node.at_css('img')['src'],
      :title => node.children[2].at_css('a').text.sub(/\n\s+/, ''),
      :price => node.children[4].text.scan(/\d+/).join.to_i,
      :bid => node.children[8].text.to_i,
      :rest_time => node.children[10].text
    }
  end

end