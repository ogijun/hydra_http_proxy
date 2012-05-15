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
    when /sm_search/
      SekaimonSearchJob.new params
    when /tb_search/
      TaobaoSearchJob.new params
    when /afn_search/
      AucfanSearchJob.new params
    when /afn_item/
      AucfanItemJob.new params
    else
      self.new params
    end
  end

  def self.filter_result body, job_filter
    if job_filter.blank? or  job_filter == 'ident'
      body
    elsif job_filter == 'afn_item'
      { :content => AucfanItemJob.extract(body) }
    elsif job_filter == 'afn_search'
      { :content => AucfanSearchJob.extract(body) }
    elsif job_filter == 'mbok_item'
      { :content => MbokItemJob.extract(body) }
    elsif job_filter == 'mbok_search'
      { :content => MbokSearchJob.extract(body) }
    elsif job_filter == 'bidders_item'
      { :content => BiddersItemJob.extract(body) }
    elsif job_filter == 'bidders_search'
      { :content => BiddersSearchJob.extract(body) }
    elsif job_filter == 'bidders_shopping_search'
      { :content => BiddersShoppingSearchJob.extract(body) }
    elsif job_filter == 'yahoo_item'
      { :content => YahooItemJob.extract(body) }
    elsif job_filter == 'yahoo_search'
      { :content => YahooSearchJob.extract(body) }
    elsif job_filter == 'yahoo_shopping_search'
      { :content => YahooShoppingSearchJob.extract(body) }
    elsif job_filter == 'rakuten_search'
      { :content => RakutenSearchJob.extract(body) }
    elsif job_filter == 'rakuten_ichiba_search'
      { :content => RakutenIchibaSearchJob.extract(body) }
    elsif job_filter == 'amazon_search'
      { :content => AmazonSearchJob.extract(body) }
    elsif job_filter == 'sekaimon_search'
      { :content => SekaimonSearchJob.extract(body) }
    elsif job_filter == 'taobao_search'
      { :content => TaobaoSearchJob.extract(body) }
    else
      nil
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

  def sort
    nil
  end

  def category
    nil
  end

  def to_json
    params.to_json
  end

end