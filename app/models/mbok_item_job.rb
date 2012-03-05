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
    auction_info = doc.at_css('#auctionInfo .in .line').css('table tr td')

    product_photo = doc.at_css('#productPhoto')
    thums = product_photo.at_css('.thum_area').css('.thum img').map { |img| img['src'] }
    pictures = product_photo.at_css('.change_area').css('.BigPicture img').map { |img| img['src'] }

    {
      :txt => txt,
      :title => title,
      :seller => seller,
      :thums => thums,
      :pictures => pictures
    }
  end

end