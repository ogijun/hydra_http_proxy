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
      results = []
      b["bundle"].each do |job|
        file = HtmlFile.by_url(job["url"]).first
        result = { :request => job, :result => { :body => file.body } }
        results.push result
      end
      headers["Content-Type"] ||= 'text/json'
      render :text => results.to_json
    end
  end


  protected
  
end
