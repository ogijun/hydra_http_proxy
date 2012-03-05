class RakutenIchibaSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => rakuten_url, :filter => 'rakuten_ichiba_search')
  end

  def rakuten_url
    opt = params['options']
    q = opt["q"].join(" ")
    base = "http://api.rakuten.co.jp/rws/3.0/json"
    "#{base}?developerId=d5f4a97417295ca07079b1574ad910f1&operation=ItemSearch&version=2010-09-15&keyword=#{q}&sort=%2BitemPrice"
  end

  def self.extract body
    data = JSON.parse body
    data["Body"]["ItemSearch"]["Items"]["Item"].map { |item| { :title => item["itemName"], :url => item["itemUrl"] } }
  end
end