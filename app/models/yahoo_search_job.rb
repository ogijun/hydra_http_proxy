class YahooSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => yahoo_url, :filter => 'yahoo_search')
  end

  def yahoo_url
    opt = params['options']
    appid = 'xqc6gaa0'
    base = 'http://auctions.yahooapis.jp/AuctionWebService/V2/json/search'
    q = opt["q"].join(" ")
    "#{base}?appid=#{appid}&query=#{q}"
  end

  def self.extract body
    data = JSON.parse(body.sub(/^loaded\(/, '').sub(/\)$/, ''))
    require 'pp'
    data_ = data['ResultSet']
    pp data_['Result']['Item'],
    { :list => data_['Result']['Item'], :count => data_['@attributes']['totalResultsAvailable'].to_i }
  end

end