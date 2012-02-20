class RawDataController < ApplicationController

  def put_urls
    urls = request.body.readlines.each(&:chomp!)
    begin
      Resque.enqueue(GetRequestsJob, urls)
      render :text => 'OK'
    rescue
      render :text => 'NG'
    end
  end

  def exists
    url = params[:url]
    if file_id = HtmlFile.exists(url)
      render :text => "OK #{file_id}"
    else
      render :text => 'NG'
    end
  end

  def get_raw
    file = HtmlFile.fresh.by_url(params[:url]).first
    render :text => file.body
  end

end
