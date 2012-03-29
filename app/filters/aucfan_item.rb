class AucfanItemJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => aucfan_url, :filter => 'aucfan_item')
  end

  def aucfan_url
    auction_id = params[:auction_id]
    site = params[:s] == 'ya' ? 'yahoo' : 'mbok'
    "http://aucfan.com/aucview/#{site}/#{auction_id}/?output=xml"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::HTML(body)
    {
      :hoge => doc.text
    }
  end

end