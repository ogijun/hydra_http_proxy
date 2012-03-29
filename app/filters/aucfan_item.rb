class AucfanItemJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => aucfan_url, :filter => 'aucfan_item')
  end

  def aucfan_url
    raise
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::HTML(body)
    {
      
    }
  end

end