class JobBundle

  def initialize bundle_data, jobs = nil
    @bundle_data = bundle_data
    @jobs = jobs
    super
  end

  def depth
    1
  end

  def jobs
    @jobs ||= @bundle_data["bundles"].map { |job| AbstractJob.build job }
  end

  def fixed?
    jobs.find_all { |job| job['url'].present }.size == jobs.size
  end

  def morph
    morphed_jobs = jobs.map { |job| job.morph }
    data = { "bundles" => morphed_jobs }
    JobBundle.new data, morphed_jobs
  end

  def extract_urls
    jobs.find_all { |job| job["url"].present? }.map { |job| job["url"] }
  end

  def enqueue
    Resque.enqueue(GetRequestsJob, self.to_json)
  end

  def to_json
    { "bundles" => jobs.map(&:params) }.to_json
  end

end