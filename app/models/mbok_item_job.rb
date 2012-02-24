class MbokItemJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => mbok_url, :filter => 'mbok_item')
  end

  def mbok_url
    "http://www.mbok.jp/item/item_#{params['auction_id']}.html"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::HTML(body)
    txt = doc.at_css('.txt').inner_html
    title = doc.at_css('.itemTitle').text
    seller = doc.at_css('#exhibition .in .line a').text
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