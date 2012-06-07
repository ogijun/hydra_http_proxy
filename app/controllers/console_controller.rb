class ConsoleController < ApplicationController
  def index
  end

  def put_orders
    @json = params[:json]
    begin
      @data = JSON.parse(@json)
      if @data['orders'].present?
        order_sheet = OrderSheet.new @data
        morphed = order_sheet.morph
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
