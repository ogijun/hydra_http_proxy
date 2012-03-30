class AucfanItemJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => aucfan_url, :filter => 'afn_item')
  end

  def aucfan_url
    auction_id = params[:auction_id]
    site = params[:site]
    "http://aucfan.com/aucview/#{site}/#{auction_id}/?output=xml"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::XML(body)
    extract_row doc.children[0]
  end

  def self.extract_row item
    {
      :auction_id => item.at_css('auctionId').text,
      :url => item.at_css('url').text,
      :title => item.at_css('title').text,
      :text => item.at_css('caption').text,
      :seller => item.at_css('seller id').text,
      :start_price => item.at_css('beginningPrice').text.to_i,
      :price => item.at_css('price').text.to_i,
      :end_time => item.at_css('endDate').text,
      :bid => item.at_css('bid').text.to_i,
      :quantity => item.at_css('amount').text.to_i,
      :pictures => item.at_css('images').children.map(&:text)
    }
  end
end