class YahooShoppingSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => yahoo_shopping_url, :filter => 'yahoo_shopping_search')
  end

  def yahoo_shopping_url
    opt = params[:options]
    appid = 'xqc6gaa0'
    base = 'http://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch'
    page = (opt['p'] || 1).to_i
    offset = (page - 1)*30
    "#{base}?appid=#{appid}&query=#{query}&hits=30&offset=#{offset}"
  end


  def self.extract body
    data = JSON.parse(body)
    count = data['ResultSet']["totalResultsAvailable"].to_i
    data_ = data['ResultSet']["0"]["Result"] rescue nil
    list = (0..29).to_a.map { |i| data_[i.to_s] }.compact.map { |item| extract_row item }
    { :list => list, :count => count }
  end

  def self.extract_row item
    {
      :title => item["Name"],
      :url => item["Url"],
      :picture => item["Image"]["Medium"],
      :thumb => item["Image"]["Small"],
      :price => item["Price"]["_value"].to_i,
      :point => item["Point"]["Amount"].to_i
    }
  end

end