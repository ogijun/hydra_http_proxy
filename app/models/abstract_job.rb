class AbstractJob
  attr_reader :params

  def self.build params
    case params["job_type"]
    when /mo_item/
      MbokItemJob.new params
    when /mo_search/
      MbokSearchJob.new params
    when /bi_search/
      BiddersSearchJob.new params
    when /ya_search/
      YahooSearchJob.new params
    when /ra_search/
      RakutenSearchJob.new params
    when /ss_search/
      SsSearchJob.new params
    else
      self.new params
    end
  end

  def initialize params
    @params = params
  end

  def [] at
    @params[at]
  end

  def morph
    self
  end

  def to_json
    params.to_json
  end

end