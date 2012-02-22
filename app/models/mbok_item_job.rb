class MbokItemJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => mbok_url)
  end

  def mbok_url
    "http://www.mbok.jp/item/item_#{params['auction_id']}.html"
  end

  def filter
  end

end