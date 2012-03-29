class AucfanSearchJob < AbstractJob

  def initialize params
    super
    @query_encoding = 'EUC-JP'
  end

  def morph
    GetApplyJob.new params.merge(:url => aucfan_url, :filter => 'afn_search')
  end

  def aucfan_url
    opt = params[:options]
    base = 'http://aucfan.search.zero-start.jp/shumaru/item_search2.cgi'
    ym = 201111 || opt['ym']
    new_params = {
      :search => query,
      :ipp => 30,
      :page => opt[:page],
      :ym => ym,
      opt[:s] => nil
    }
    "#{base}?#{new_params.to_query}"
  end

  def self.extract body
    require 'stringio'
    str = StringIO.new body
    site, count = str.gets.chomp.split(':')
    list = []
    str.readlines.each do |row|
      unless row =~ /^<\/html>/
        cols = row.split "\t"
        item = {
          :site => site,
          :title => cols[4],
          :bid => cols[0],
          :price => cols[1],
          :end => cols[2],
          :auction_id => cols[3]
        }
        list.push item
      end
    end
    { :list => list, :count => count.to_i }
  end

end