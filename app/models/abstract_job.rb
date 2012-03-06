class AbstractJob
  attr_reader :params
  attr_reader :query_encoding

  def self.build params
    case params["job_type"]
    when /mo_item/
      MbokItemJob.new params
    when /mo_search/
      MbokSearchJob.new params
    when /bi_item/
      BiddersItemJob.new params
    when /bi_search/
      BiddersSearchJob.new params
    when /bis_search/
      BiddersShoppingSearchJob.new params
    when /ya_item/
      YahooItemJob.new params
    when /ya_search/
      YahooSearchJob.new params
    when /yas_search/
      YahooShoppingSearchJob.new params
    when /ra_search/
      RakutenSearchJob.new params
    when /rai_search/
      RakutenIchibaSearchJob.new params
    when /am_search/
      AmazonSearchJob.new params
    when /ss_search/
      SsSearchJob.new params
    else
      self.new params
    end
  end

  def initialize params
    @params = params.with_indifferent_access
  end

  def [] at
    params[at]
  end

  def morph
    self
  end

  def query
    URI.escape(params[:options][:q].join(' ').encode(query_encoding || 'UTF-8'))
  end

  def to_json
    params.to_json
  end

end