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
    # base = 'http://aucfan.search.zero-start.jp/api/compat/item_search2.cgi'
    # base = 'http://192.168.2.58/shumaru/item_search2.cgi'
    base = 'http://210.152.140.226/api/compat/item_search2.cgi'
    ym = opt[:ym] # || 201202
    sort = (opt[:sort] || 'date desc').split(/\s/)

    new_params = {
      :search => query,
      :ipp => 30,
      :c_ya => opt[:c_ya],
      :page => opt[:page],
      :ym => ym,
      :sort => sort[0],
      :rev => (sort[1] == 'desc' ? 0 : 1),
      :ya => '',
      opt[:s] => ''
    }
    "#{base}?#{new_params.to_query}"
  end

  def self.page_id aid
    yahoo_auction_page_id = {
      'a' => '',
      'b' => 'page2',
      'c' => 'page3',
      'd' => 'page4',
      'e' => 'page5',
      'f' => 'page6',
      'g' => 'page7',
      'h' => 'page8',
      'i' => 'koubai',
      'j' => 'page21',
      'k' => 'page9',
      'l' => 'page22',
      'm' => 'page10',
      'n' => 'page11',
      'o' => '',
      'p' => 'page12',
      'q' => '',
      'r' => 'page13',
      's' => 'page14',
      't' => 'page15',
      'u' => 'page16',
      'v' => 'page17',
      'w' => 'page18',
      'x' => 'page19',
      'y' => 'page20',
      'z' => ''
    }
    yahoo_auction_page_id[aid[0]]
  end

  def self.extract body
    return if body.blank?
    # FIXME: correct property name
    require 'stringio'
    str = StringIO.new body
    site, count = str.gets.chomp.split(':')
    list = []
    str.readlines.each do |row|
      unless row =~ /^<\/html>/
        cols = row.split "\t"
        auction_id = cols[4]
        sub = (page_id = page_id(auction_id)).present? ? page_id + '.' : ''
        item = {
          :auction_id => auction_id,
          :aucview_url => "/aucview/yahoo/#{auction_id}/",
          :url => (url = "http://#{sub}auctions.yahoo.co.jp/auction/#{auction_id}"),
          :affiliate_url => url,
          :site => site,
          :title => cols[5],
          :bid => cols[0],
          :start_price => cols[1],
          :price => cols[2],
          :end_time => cols[3],
          :end_date => (end_date = Time.at(cols[3].to_i - 15*3600).strftime('%Y%m%d')),
          :img => "http://aucfan.com/item_data/thumbnail/#{end_date}/yahoo/#{auction_id[0]}/#{auction_id}.jpg"
        }
        list.push item
      end
    end
    { :list => list, :count => count.to_i }
  end

end