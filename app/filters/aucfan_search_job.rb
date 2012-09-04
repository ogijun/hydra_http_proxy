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
    # base2 = 'http://192.168.2.58/shumaru/item_search2.cgi'
    # base3 = 'http://192.168.2.74//item_search3.cgi'
    base2 = 'http://210.152.140.226/api/compat/item_search2.cgi'
    base3 = 'http://210.152.140.226/api/compat/item_search3.cgi'

    if opt[:s] == 'mix'
      base = base3
      opt_s = ''
    else
      base = base2
      opt_s = "&#{opt[:s]}"
    end

    ym = opt[:ym]
    sort = opt[:sort].split(' ')
    sort[0] = ['date', 'price', 'bid'].include?(sort[0]) ? sort[0] : 'date'
    sort[1] = ['asc', 'desc'].include?(sort[1]) ? sort[1] : 'asc'

    new_params = {
      :search => query,
      :ipp => 30,
      :page => opt[:page],
      :ym => ym,
      :sort => sort[0],
      :rev => (sort[1] == 'desc' ? 0 : 1),
    }
    "#{base}?#{new_params.to_query}" + opt_s
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
    site, count = str.gets.chomp[1..-1].split(':')
    list = []
    str.readlines.each do |row|
      unless row =~ /^<\/html>/
        list.push extract_item(row, site)
      end
    end
    { :list => list, :count => count.to_i, :site => site }
  end

  def self.extract_item row, site
    case site
    when 'yahoo'
      extract_item_ya row
    when 'mix'
      extract_item_mix row
    end
  end

  def self.extract_item_ya row
    cols = row.split "\t"
    auction_id = cols[4]
    sub = (page_id = page_id(auction_id)).present? ? page_id + '.' : ''
    end_time = Time.at(cols[3].to_i - 15*3600)
    end_date = end_time.strftime('%Y%m%d')
    item = {
      :site => 'ya',
      :title => cols[5],
      :aid => auction_id,
      :price => cols[2],
      :priceFormatted => cols[2],
      :bid => cols[0].to_i,
      :time => end_time.strftime('%Y-%m-%d'),
      :timeFormatted => end_time.strftime('%Y-%m-%d'),
      :thumbnail => "http://aucfan.com/item_data/thumbnail/#{end_date}/yahoo/#{auction_id[0]}/#{auction_id}.jpg",
      :aucviewurl => "/aucview/yahoo/#{auction_id}/",
      :url => (url = "http://#{sub}auctions.yahoo.co.jp/auction/#{auction_id}"),
      :realsiteurl => url,
      :sellerId => cols[7],
      :startPrice => cols[1].to_i,
      :syuppinItemCount => cols[8].to_i
    }
  end

  def self.extract_item_mix row
    cols = row.split "\t"
    auction_id = cols[6]
    sub = (page_id = page_id(auction_id)).present? ? page_id + '.' : ''
    end_time = Time.at(cols[5].to_i - 15*3600)
    end_date = end_time.strftime('%Y%m%d')
    item = {
      :site => col[0],
      :title => cols[7],
      :aid => auction_id,
      :price => cols[4],
      :priceFormatted => cols[4],
      :bid => cols[1].to_i,
      :time => end_time.strftime('%Y-%m-%d'),
      :timeFormatted => end_time.strftime('%Y-%m-%d'),
      :thumbnail => "http://aucfan.com/item_data/thumbnail/#{end_date}/yahoo/#{auction_id[0]}/#{auction_id}.jpg",
      :aucviewurl => "/aucview/yahoo/#{auction_id}/",
      :url => (url = "http://#{sub}auctions.yahoo.co.jp/auction/#{auction_id}"),
      :realsiteurl => url,
      :sellerId => nil,
      :startPrice => cols[3].to_i,
      :syuppinItemCount => nil
    }
  end

end