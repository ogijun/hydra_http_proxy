class SsSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => ss_url, :filter => 'ss_search')
  end

  def ss_url
    opt = params['options']
    base = 'http://aucfan.search.zero-start.jp/shumaru/item_search2.cgi'
    q = opt["q"].join(" ")
    ym = 201111 || opt['ym']
    "#{base}?search=#{q}&ipp=30&page=#{opt['page']}&ym=#{ym}&#{opt['s']}"
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