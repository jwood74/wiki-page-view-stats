def find_movies_on_page(page)
  movies = []
  doc = nokogiri_from_url(page[:link])
  tables = doc.xpath(".//table[@class='wikitable' or @class='wikitable sortable']")
  puts page[:link] + ' - ' + tables.count.to_s
  tables.each do |tb|
    header = tb.at_xpath('tbody/tr')
    next unless ['Opening', 'Title'].include? header.at_xpath('th').text.strip

    movie_col = 0
    header.xpath('th').each_with_index do |c, i|
      next unless c.text.strip == 'Title'

      movie_col = i
      break
    end
    tb.xpath('tbody/tr').each do |r|
      next if r == header
      next unless r.xpath('td//a').count.positive?

      mv = r.at_xpath('td//a')
      next if mv['href'].include? 'redlink=1'

      begin
        movies << { 'region' => page[:region], 'name' => mv.text, 'year' => page[:year], 'link' => mv['href'] }
      rescue
        p mv
        exit
      end
    end
  end
  puts "#{movies.count} movies found"
  movies
end