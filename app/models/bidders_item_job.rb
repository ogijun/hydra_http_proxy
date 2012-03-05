class BiddersItemJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => bidders_url, :filter => 'bidders_item')
  end

  def bidders_url
    "http://www.bidders.co.jp/aitem/#{params['auction_id']}"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::HTML(body)

    txt = doc.at_css('.udl').inner_html
    title = doc.at_css('h1').text
    seller = doc.css('table')[4].at_css('a').text[0..-4]
    thum = doc.xpath("//img[@width='240']")[0][:src]
    # TODO: pic

    {
      :txt => txt,
      :title => title,
      :seller => seller,
      :thums => [thum]
      # :pictures => pictures
    }
  end

end