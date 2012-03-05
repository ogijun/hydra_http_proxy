class YahooItemJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => yahoo_url, :filter => 'yahoo_item')
  end

  def yahoo_url
    appid = 'xqc6gaa0'
    base = 'http://auctions.yahooapis.jp/AuctionWebService/V2/json/auctionItem'
    "#{base}?appid=#{appid}&auctionid=#{params['auction_id']}"
  end

  def self.extract body
    data = JSON.parse(body.sub(/^loaded\(/, '').sub(/\)$/, ''))
    extract_row data['ResultSet']['Result']
  end

  def self.extract_row item
    {
      :auction_id => item['AuctionID'],
      :url => item['AuctionItemUrl'],
      :title => item['Title'],
      :text => item['Description'],
      :seller => item['Seller']['Id'],
      :start_price => item['InitPrice'].to_i,
      :price => item['Price'].to_i,
      :end_time => item['EndTime'],
      :bid => item['Bids'].to_i,
      :quantity => item['Quantity'].to_i,
      :pictures => item['Img'].values
    }
  end
end