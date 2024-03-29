class RakutenIchibaSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => rakuten_url, :filter => 'rakuten_ichiba_search')
  end

  def rakuten_url
    opt = params[:options]
    base = "http://api.rakuten.co.jp/rws/3.0/json"
    new_params = {
      :developerId => 'd5f4a97417295ca07079b1574ad910f1',
      :operation => 'ItemSearch',
      :version => '2010-09-15',
      :keyword => query,
      :sort => sort
    }
    "#{base}?#{new_params.to_query}"
  end

  def sort
    '-reviewCount'
  end

  def self.extract body
    data = JSON.parse body
    data["Body"]["ItemSearch"]["Items"]["Item"].map { |item| extract_row item }
  end

  def self.extract_row item
    {
      :title => item["itemName"],
      :url => item["itemUrl"],
      :price => item['itemPrice'].to_i,
      :point => (item['itemPrice'].to_i*(item['pointRate'].to_f/100.0)).floor
    }
  end

end