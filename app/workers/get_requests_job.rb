class GetRequestsJob
  require 'pp'
  @queue = :get_requests

  def self.perform(data)
    begin
      bundle = JSON.parse(data)["bundle"]
      pp bundle
      urls = bundle.map{ |a| a['url'] }
      requests = urls.map { |url| rrr url }
      responses = rrrr requests
      wwww responses
    rescue Exception => e
      pp e
      pp e.backtrace
    end
  end

  def self.rrr url
    pp url
    request = Typhoeus::Request.new(
      url,
      # :body          => "this is a request body",
      :method        => :get,
      # :headers       => {:Accept => "text/html"},
      :timeout       => 1000, # milliseconds
      :cache_timeout => 60, # seconds
      :follow_location => true
      # :params        => {:field1 => "a field"}
    )
  end

  def self.rrrr requests
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

  def self.wwww responses
    responses.each do |r|
      filename = Digest::MD5.hexdigest(r.request.url)
      File.open("#{Rails.root}/tmp/#{filename}", 'w') do |f|
        f.puts r.inspect
      end
      HtmlFile.create_or_update_by_url(:url => r.request.url, :url_hash => filename, :body => translate(r.body))
    end
  end

end