class AucfanItemJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => aucfan_url, :filter => 'afn_item')
  end

  def aucfan_url
    auction_id = params[:auction_id]
    site = params[:site]
    "http://60.36.190.45/aucview/#{site}/#{auction_id}/?output=xml"
  end

  require 'nokogiri'
  def self.extract body
    doc = Nokogiri::XML(body)
    extract_row doc.children[0]
  end

  def self.extract_row item
    {
      :auctionId => item.at_css('auctionId').text,
      :title => item.at_css('title').text,
      :site => item.at_css('site').text,
      :categoryId => item.at_css('categoryId').text,
      :affiliateUrl => item.at_css('url').text,
      :url => item.at_css('url').text,
      :mobileUrl => item.at_css('url').text,
      :limit => item.at_css('limit').text,
      :beginningDate => item.at_css('beginningDate').text,
      :endDate => item.at_css('endDate').text,
      :beginningPrice => item.at_css('beginningPrice').text,
      :price => item.at_css('price').text,
      :amount => item.at_css('amount').text,
      :bid => item.at_css('bid').text.to_i,
      :bidUnit => item.at_css('bidUnit').text.to_i,
      :seller => {
        :id => item.at_css('seller id').text,
        :evalUrl => item.at_css('seller evalUrl').text,
        :mobileEvalUrl => item.at_css('seller mobileEvalUrl').text,
        :mobileAffiliateEvalUrl => item.at_css('seller mobileAffiliateEvalUrl').text,
        :mobileItemUrl => item.at_css('seller mobileItemUrl').text,
        :mobileAffiliateItemUrl => item.at_css('seller mobileAffiliateItemUrl').text,
      },
      :images => item.at_css('images').children.map(&:text)
    }
  end
end