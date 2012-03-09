class ConsoleController < ApplicationController
  def index
  end

  def put_bundle
    @json = params[:json]
    begin
      @data = JSON.parse(@json)
      if @data['bundle'].present?
        job_bundle = JobBundle.new @data
        morphed = job_bundle.morph
        morphed.enqueue
        @saved_key = morphed.save $redis
      end
    rescue JSON::ParserError => e
      @data = 'Not JSON'
    end
  end

  def get_result
    
  end
end
