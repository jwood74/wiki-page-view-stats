require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'nokogiri'

def json_from_url(url)
  JSON.parse(xml_from_url(url))
end

def xml_from_url(url)
  uri = URI(url)
  Net::HTTP.get(uri)
end

def nokogiri_from_url(url)
  Nokogiri::HTML(xml_from_url(url)) do |config|
    config.strict.noblanks
  end
end

def get_page_views(page:, period: 'daily', from:, to:)
  uri = URI.parse("https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/en.wikipedia/all-access/user/#{page}/#{period}/#{from}/#{to}")

  request = Net::HTTP::Get.new(uri)
  request['Api-User-Agent'] = 'Jaxen Wood jwood74@gmail.com'

  req_options = { use_ssl: uri.scheme == 'https' }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  JSON.parse(response.body)['items']
end

def get_page_names(pages)
  tmp = {}
  pages.each_with_index do |a, i|
    print "#{i}/#{pages.count}\r"
    pg = nokogiri_from_url(a['link'])
    title = pg.at_xpath('.//title').text.chomp(' - Wikipedia')
    tmp[a['link'].split('wiki/').last] = a.to_hash
    tmp[a['link'].split('wiki/').last]['title'] = title
  end
  tmp
end

def get_view_data(pages, from, to)
  pages.keys.each do |pg|
    page = pages[pg]
    data = get_page_views(page: pg, from: from, to: to)
    page['views'] = {}
    next unless data

    data.each do |d|
      page['views'][d['timestamp']] = d['views']
    end
  end
  pages
end

def dump_pages_to_csv(pages, folder)
  CSV.open("#{folder}/page_list.csv", 'wb') do |csv| 
    csv << pages[pages.keys.first].keys
    pages.to_a.each { |k, v| csv << v.values }
  end
end

def dump_page_views_to_csv(pages, folder)
  CSV.open("#{folder}/page_views.csv", 'wb') do |csv| 
    csv << pages[pages.keys.first].keys + ['date']
    pages.to_a.each do |pg| 
      pg[1]['views'].keys.each do |v|
        csv << pg[1].values[0..-2] + [pg[1]['views'][v], v]
      end
    end
  end
end

def get_days(page_views)
  page_views.values.map { |x| x['views'].keys }[0].uniq
end

def reformat_page_views(page_views, folder, method = 'cumulative')
  days = get_days(page_views)
  CSV.open("#{folder}/page_views_wide.csv", 'wb') do |csv|
    csv << page_views[page_views.keys.first].keys[1..-2] + days.sort.map { |d| DateTime.parse(d).to_date.to_s }
    page_views.values.each_with_index do |m, j|
      print "#{j}/#{page_views.keys.count}\r"
      tmp = m.values[1..-2]
      val = []
      days.sort.each do |k|
        if m['views'][k]
          val << m['views'][k].to_i
        else
          val << 0
        end
        tmp << val.last(30).sum
      end
      csv << tmp
    end
  end
end
