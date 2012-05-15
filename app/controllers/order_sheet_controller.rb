class OrderSheetController < ApplicationController

  def put
    order_sheet_json = order_from_request
    if order_sheet_json
      order_sheet = OrderSheet.new order_sheet_json
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
      job_results = OrderSheet.get_result_from_cache OrderSheet.new(JSON.parse(bj))
      headers["Content-Type"] ||= 'application/json'
      render :text => job_results.to_json
    end
  end

  def put_and_get
    order_sheet_json = order_from_request
    if order_sheet_json
      order_sheet = OrderSheet.new order_sheet_json
      morphed = order_sheet.morph
      hydra_responses = OrderSheet.hydra_run_orders morphed.orders
      OrderSheet.write_cache hydra_responses

      job_results = OrderSheet.get_result_from_cache morphed
      headers["Content-Type"] ||= 'application/json'
      render :text => job_results.to_json
    end
  end

  protected
  def order_from_request
    body = request.body.read
    begin
      JSON.parse body
    rescue JSON::ParserError => e
      logger.debug e
      nil
    end
  end


end
