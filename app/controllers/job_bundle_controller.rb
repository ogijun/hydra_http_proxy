class JobBundleController < ApplicationController
  require 'digest/md5'

  def put
    body = request.body.read
    begin
      decoded = JSON.parse body
      job_bundle = JobBundle.new decoded
      morphed = job_bundle.morph
      morphed.enqueue
      value = morphed.to_json
      key = Digest::MD5.hexdigest(value)
      $redis.set("get_req:#{key}", value)
      $redis.expire("get_req:#{key}", 3600)
      render :text => key
      logger.debug job_bundle.to_json.inspect
      logger.debug morphed.to_json.inspect
    rescue JSON::ParserError => e
      logger.debug e
      render :text => 'Not JSON'
    end
  end

  def get_result
    id = params[:id]
    bj = $redis.get("get_req:#{id}")
    if bj.blank?
      render :text => 'No Job'
    else
      b = JSON.parse(bj)
      job_results = []
      b["bundles"].each do |job|
        file = HtmlFile.by_url(job["url"]).first
        job_filter = job["filter"]
        if job_filter.blank? or  job_filter == 'ident'
          result = file.body
        elsif job_filter == 'mbok_item'
          result = { :content => MbokItemJob.extract(file.body) }
        elsif job_filter == 'mbok_search'
          result = { :content => MbokSearchJob.extract(file.body) }
        elsif job_filter == 'bidders_item'
          result = { :content => BiddersItemJob.extract(file.body) }
        elsif job_filter == 'bidders_search'
          result = { :content => BiddersSearchJob.extract(file.body) }
        elsif job_filter == 'yahoo_search'
          result = { :content => YahooSearchJob.extract(file.body) }
        elsif job_filter == 'rakuten_search'
          result = { :content => RakutenSearchJob.extract(file.body) }
        elsif job_filter == 'ss_search'
          result = { :content => SsSearchJob.extract(file.body) }
        else
        end
        job_results.push({ :request => job, :result => result })
      end
      headers["Content-Type"] ||= 'application/json'
      render :text => job_results.to_json
    end
  end


  protected
  
end
