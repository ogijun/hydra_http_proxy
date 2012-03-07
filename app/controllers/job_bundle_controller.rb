class JobBundleController < ApplicationController

  def put
    body = request.body.read
    begin
      decoded = JSON.parse body
      job_bundle = JobBundle.new decoded
      morphed = job_bundle.morph
      morphed.enqueue
      saved_key = morphed.save $redis
      render :text => saved_key
      logger.debug morphed.inspect
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
      job_results = JobBundle.get_result JSON.parse(bj)
      headers["Content-Type"] ||= 'application/json'
      render :text => job_results.to_json
    end
  end

end
