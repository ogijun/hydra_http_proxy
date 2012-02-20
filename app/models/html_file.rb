class HtmlFile < ActiveRecord::Base
  require 'digest/md5'
  scope :fresh, where('updated_at > ?', Time.now - 1.day)
  scope :by_url, lambda { |url| where(:url => url) }

  def write
    filename = Digest::MD5.hexdigest(url)
    File.open("#{Rails.root}/tmp/#{filename}",'w') do |f|
      f.puts body
    end
  end

  def self.exists url
    by_url(url).present?
  end

  def self.create_or_update_by_url params
    s = by_url(params[:url])
    if s.present?
      s.first.update_attributes params
    else
      s.create params.merge(:url_hash => Digest::MD5.hexdigest(params[:url]))
    end
  end


end
