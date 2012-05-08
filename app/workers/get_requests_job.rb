class GetRequestsJob
  require 'pp'
  @queue = :get_requests

  def self.perform(data)
    begin
      orders = JSON.parse(data)["orders"]
      pp orders
      hydra_responses = hydra_run_orders orders
      write_cache hydra_responses
    rescue Exception => e
      pp e
      pp e.backtrace
    end
  end

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
        :timeout       => 1000, # milliseconds
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

end