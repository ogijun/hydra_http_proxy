class YahooSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => yahoo_url, :filter => 'yahoo_search')
  end

  def yahoo_url
    opt = params[:options]
    appid = 'xqc6gaa0'
    base = 'http://auctions.yahooapis.jp/AuctionWebService/V2/json/search'
    "#{base}?appid=#{appid}&query=#{query}"
  end

  def self.extract body
    data = JSON.parse(body.sub(/^loaded\(/, '').sub(/\)$/, ''))
    data_ = data['ResultSet']
    list = data_['Result']['Item'].map { |item| extract_row item }
    { :list => list, :count => data_['@attributes']['totalResultsAvailable'].to_i }
  end

  def self.extract_row item
    {
      :auction_id => item['AuctionID'],
      :url => item['ItemUrl'],
      :title => item['Title'],
      :seller => item['Seller']['Id'],
      :price => item['CurrentPrice'].to_i,
      :end_time => item['EndTime'],
      :bid => item['Bids'].to_i,
      :img => item['Image']
    }
  end

end