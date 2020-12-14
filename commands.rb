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
  response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http| http.request(request) }
  JSON.parse(response.body)['items']
end

def get_page_name(page)
  print "#{page}                      \r"
  pg = nokogiri_from_url("https://en.wikipedia.org/wiki/#{page}")
  pg.at_xpath('.//title').text.chomp(' - Wikipedia')
end

def load_json(folder)
  JSON.parse(File.read("#{folder}/#{folder}.json"))
end

def update_json(pages, folder)
  File.open("#{folder}/#{folder}.json", 'w') { |f| f << pages.to_json }
end

def get_input(text, input, len = nil)
  result = ''
  if input
    result = input
  else
    puts text
    result = STDIN.gets.chomp
  end
  return result if result == 'skip'
  return result.to_s.ljust(len, '0') if len

  result
end

def fix_links(pages)
  pages.each do |g|
    g['link'] = g['link'].split('wiki/').last
  end
end

def get_view_data(pages, from, to)
  pages['pages'].keys.each do |pg|
    next unless new_views_required(pages['pages'][pg], from, to)
    
    print "#{pages['pages'][pg]['title']}                      \r"

    data = get_page_views(page: pg, from: from, to: to)
    pages['pages'][pg]['views'] = {} unless pages['pages'][pg]['views']
    next unless data

    data.each do |d|
      pages['pages'][pg]['views'][d['timestamp']] = d['views']
    end
    pages['pages'][pg]['from'] = pages['pages'][pg]['views'].keys.min
    pages['pages'][pg]['to'] = pages['pages'][pg]['views'].keys.max
  end
  pages
end

def create_json_for_pages(pages, folder)
  tmp = { 'fields' => ['title'] + (pages.headers - ['title', 'link']), 'pages' => {} }
  pages.each { |g| tmp['pages'][g['link']] = g.to_hash }
  File.open("#{folder}/#{folder}.json", 'w') { |f| f << tmp.to_json }
end

def new_views_required(data, from, to)
  required =
    if data['from'].nil?
      true
    elsif data['from'] > from
      true
    else
      data['to'] < to
    end
  required
end

def export_page_views(pages, folder)
  CSV.open("#{folder}/#{folder}.csv", 'wb') do |csv|
    csv << pages['fields'] + pages['dates'].sort.map { |d| DateTime.parse(d).to_date.to_s }
    pages['pages'].values.each_with_index do |m, j|
      print "#{j}/#{pages['pages'].keys.count}\r"
      tmp = pages['fields'].map { |f| m[f] }
      val = []
      pages['dates'].sort.each do |k|
        val << if m['views'][k]
                 m['views'][k].to_i
               else
                 0
               end
        tmp << val.last(14).sum
      end
      csv << tmp
    end
  end
end

def add_new_people_to_json(pages, input)
  input.each do |i|
    pages['pages'][i['link']] = i.to_hash unless pages['pages'][i['link']]
    pages['pages'][i['link']]['title'] = get_page_name(i['link']) unless pages['pages'][i['link']]['title']
  end
end

def add_new_dates(pages)
  mindate = "#{Float::INFINITY}"
  maxdate = "0"
  pages['dates'] = [] unless pages['dates']
  pages['pages'].values.each do |v|
    next unless v['views'].keys.count.positive?

    pages['dates'] |= v['views'].keys
    mindate = v['views'].keys.min if mindate > v['views'].keys.min
    maxdate = v['views'].keys.max if maxdate < v['views'].keys.max
  end
  pages['from'] = mindate
  pages['to'] = maxdate
end

def scrape_page_for_items(folder, site, item_code)
  page = nokogiri_from_url(site)

  items = page.xpath(item_code)

  CSV.open("#{folder}/input.csv","w") do |c|
    c << ['link','title']
    items.each do |i|
      c << [i['href'],i.text.strip]
    end
  end
end
