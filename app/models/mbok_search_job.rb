class MbokSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => mbok_url)
  end

  def mbok_url
    "http://www.mbok.jp/-l?q=#{params["q"]}"
  end

  def filter
    
  end
end