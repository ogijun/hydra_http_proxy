class GetRequestsJob
  require 'pp'
  @queue = :get_requests

  def self.perform(data)
    begin
      os = OrderSheet.new(JSON.parse(data))
      pp os
      hydra_responses = os.hydra_run_orders
      pp hydra_responses
      OrderSheet.write_cache hydra_responses
    rescue Exception => e
      pp e
      pp e.backtrace
    end
  end

end