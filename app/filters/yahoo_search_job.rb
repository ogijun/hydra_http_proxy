class YahooSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => yahoo_url, :filter => 'yahoo_search')
  end

  def yahoo_url
    opt = params[:options]
    appid = 'xqc6gaa0'
    base = 'http://auctions.yahooapis.jp/AuctionWebService/V2/json/search'
    page = (opt[:page] || 1).to_i
    offset = (page - 1)*30
    new_params = {
      :appid => appid,
      :query => query,
      :hits => 30,
      :offset => offset,
      :sort => sort,
      :order => 'd'
    }
    "#{base}?#{new_params.to_query}"
  end

  def sort
    "bids"
  end

  def category
    ''
  end

  def self.extract body
    require 'pp'
    pp :body => body
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