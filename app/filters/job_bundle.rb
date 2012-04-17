class JobBundle
  require 'digest/md5'

  def self.get_result data
    job_results = []
    data["bundle"].each do |job|
      file = HtmlFile.by_url(job["url"]).first
      file_body = file.try(:body)
      job_filter = job["filter"]
      result = filter_result file_body, job_filter
      job_results.push({ :request => job, :result => result })
    end
    job_results
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
    else
      nil
    end
  end

  def initialize bundle_data, jobs = nil
    @bundle_data = bundle_data
    @jobs = jobs
    super
  end

  def depth
    1
  end

  def jobs
    @jobs ||= @bundle_data["bundle"].map { |job| AbstractJob.build job }
  end

  def fixed?
    jobs.find_all { |job| job['url'].present }.size == jobs.size
  end

  def morph
    morphed_jobs = jobs.map { |job| job.morph }
    data = { "bundle" => morphed_jobs }
    JobBundle.new data, morphed_jobs
  end

  def extract_urls
    jobs.find_all { |job| job["url"].present? }.map { |job| job["url"] }
  end

  def enqueue
    Resque.enqueue(GetRequestsJob, self.to_json)
  end

  def save redis
    value = self.to_json
    key = Digest::MD5.hexdigest(value)
    redis.set("get_req:#{key}", value)
    redis.expire("get_req:#{key}", 3600)
    key
  end

  def to_json
    { "bundle" => jobs.map(&:params) }.to_json
  end

end