class AbstractJob
  attr_reader :params

  def self.build params
    case params["job_type"]
    when /mbok_item/
      MbokItemJob.new params
    when /mbok_search/
      MbokSearchJob.new params
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