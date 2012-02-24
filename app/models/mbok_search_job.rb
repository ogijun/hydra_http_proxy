class MbokSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => mbok_url, :filter => 'mbok_search')
  end

  def mbok_url
    opt = params[:options]
    "http://www.mbok.jp/_l?q=#{opt["q"]}&p=#{opt["p"]}"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::HTML(body)
    list = doc.css('.li_title2').map { |node| extract_row node }
    count = doc.at_css('.pagelink span').text.scan(/\d+/).first.to_i
    { :list => list, :count => count }
  end

  def self.extract_row node
    {
      :text => node.at_css('.title').text,
      :url => node.css('a')[1]['href'],
      :seller => node.css('a')[2].text,
      :price => node.at_css('.li_price').text,
      :bid => node.at_css('.li_bid').text,
      :time => node.at_css('.li_time').text,
      :bid => node.at_css('.li_bid').text,
      :img => node.at_css('.imgbox img')['src'],
    }
  end
end