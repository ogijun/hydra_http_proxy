class RakutenSearchJob < AbstractJob

  def morph
    GetApplyJob.new params.merge(:url => rakuten_url, :filter => 'rakuten_search')
  end

  def rakuten_url
    base = "http://esearch.rakuten.co.jp/rms/sd/esearch/vc"
    opt = params['options']
    page = opt['page'].to_i - 1
    g = 1050000000
    s = 3
    "#{base}?sv=13&f=A&g=#{g}&v=2&e=0&p=#{page}&s=#{s}&oid=000&sub=1&k=0&sf=1&sitem=#{opt['q']}&x=0"
  end

  def self.extract body
    { :list => body, :count => nil }
  end

end