class OrderSheetController < ApplicationController

  def put
    order_sheet = order_sheet_from_request
    if order_sheet
      morphed = order_sheet.morph
      morphed.enqueue
      logger.debug morphed.inspect
      saved_key = morphed.save $redis
      render :text => saved_key
    else
      render :text => 'Not JSON'
    end
  end

  def get_result
    id = params[:id]
    bj = $redis.get("get_req:#{id}")
    if bj.blank?
      render :text => 'No Job'
    else
      order_sheet = OrderSheet.new JSON.parse(bj)
      job_results = order_sheet.get_result_from_cache
      headers["Content-Type"] ||= 'application/json'
      render :text => job_results.to_json
    end
  end

  def put_and_get
    order_sheet = order_sheet_from_request
    if order_sheet
      morphed = order_sheet.morph
      hydra_responses = morphed.hydra_run_orders
      OrderSheet.write_cache hydra_responses

      job_results = morphed.get_result_from_cache
      headers["Content-Type"] ||= 'application/json'
      render :text => job_results.to_json
    end
  end

  protected
  def order_sheet_from_request
    body = request.body.read
    begin
      parsed_body = JSON.parse body
      OrderSheet.new parsed_body
    rescue JSON::ParserError => e
      logger.debug e
      nil
    end
  end


end
