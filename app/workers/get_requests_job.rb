class GetRequestsJob
  require 'pp'
  @queue = :get_requests

  def self.perform(data)
    begin
      orders = JSON.parse(data)["orders"]
      pp orders
      hydra_responses = OrderSheet.hydra_run_orders orders
      pp hydra_responses
      OrderSheet.write_cache hydra_responses
    rescue Exception => e
      pp e
      pp e.backtrace
    end
  end

end