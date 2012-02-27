class AbstractJob
  attr_reader :params

  def self.build params
    case params["job_type"]
    when /mbok_item/
p 3
      MbokItemJob.new params
    when /mbok_search/
p 2
      MbokSearchJob.new params
    when /bidders_search/
p 1
      BiddersSearchJob.new params
    else
      self.new params
    end
  end

  def initialize params
    @params = params
  end

  def [] at
    @params[at]
  end

  def morph
    self
  end

  def to_json
    params.to_json
  end

end