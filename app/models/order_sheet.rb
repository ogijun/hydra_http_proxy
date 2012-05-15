class OrderSheet
  require 'digest/md5'

  def self.hydra_run_orders orders
    hydra_requests = requests_from_orders(orders)
    hydra_run(hydra_requests)
  end

  def self.requests_from_orders orders
    urls = orders.map{ |a| a['url'] }
    requests = urls.map { |url|
      Typhoeus::Request.new(
        url,
        # :body          => "this is a request body",
        :method        => :get,
        # :headers       => {:Accept => "text/html"},
        :timeout       => 10000, # milliseconds
        :cache_timeout => 60, # seconds
        :follow_location => true
        # :params        => {:field1 => "a field"}
      )
    }
  end

  def self.hydra_run requests
    pp requests
    # Run the request via Hydra.
    hydra = Typhoeus::Hydra.new
    requests.each { |request| hydra.queue(request) }
    hydra.run
    pp requests
    requests.map(&:response)
  end

  def self.ugly_guess_jp str
    %w[UTF-8 EUC-JP Shift_JIS eucJP-ms Windows-31J].find do |encoding|
      begin
        tested = str.force_encoding(encoding)
        tested.valid_encoding? && tested.encode('UTF-8').valid_encoding?
      rescue Encoding::UndefinedConversionError => e
        nil
      end
    end
  end

  def self.translate str
    enc = ugly_guess_jp str
    translated = str.force_encoding(enc).encode('UTF-8')
  end

  def self.write_cache responses
    responses.each do |r|
      filename = Digest::MD5.hexdigest(r.request.url)
      File.open("#{Rails.root}/tmp/#{filename}", 'w') do |f|
        f.puts r.inspect
      end
      HtmlFile.create_or_update_by_url(:url => r.request.url, :url_hash => filename, :body => translate(r.body))
    end
  end

  def self.get_result_from_cache data
    p 'OderSheet::get_result_from_cache :data => ' + data.inspect
    job_results = []
    data.orders.each do |job|
      file = HtmlFile.by_url(job["url"]).first
p :file => file
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
    elsif job_filter == 'sekaimon_search'
      { :content => SekaimonSearchJob.extract(body) }
    elsif job_filter == 'taobao_search'
      { :content => TaobaoSearchJob.extract(body) }
    else
      nil
    end
  end

  def initialize data, orders = nil
    @data = data
    @orders = orders
    super
  end

  def depth
    1
  end

  def orders
    @orders ||= @data["orders"].map { |job| AbstractJob.build job }
  end

  def fixed?
    orders.find_all { |job| job['url'].present }.size == orders.size
  end

  def morph
    morphed_orders = orders.map { |job| job.morph }
    data = { "orders" => morphed_orders }
    OrderSheet.new data, morphed_orders
  end

  def extract_urls
    orders.find_all { |job| job["url"].present? }.map { |job| job["url"] }
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
    { "orders" => orders.map(&:params) }.to_json
  end

end