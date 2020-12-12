require_relative 'commands'
require_relative 'movie_commands'

pages = [
  # { region: 'US', year: 2018, link: 'https://en.wikipedia.org/wiki/List_of_American_films_of_2018'},
  { region: 'US', year: 2019, link: 'https://en.wikipedia.org/wiki/List_of_American_films_of_2019'},
  # { region: 'US', year: 2020, link: 'https://en.wikipedia.org/wiki/List_of_American_films_of_2020'},
  { region: 'AU', year: 2019, link: 'https://en.wikipedia.org/wiki/List_of_Australian_films_of_2019' },
  { region: 'UK', year: 2019, link: 'https://en.wikipedia.org/wiki/List_of_British_films_of_2019' },
  { region: 'CA', year: 2019, link: 'https://en.wikipedia.org/wiki/List_of_Canadian_films_of_2019' },
]

movies = []
days = {}

pages.each do |pg|
  movies += find_movies_on_page(pg)
end

# puts 'getting the page views'

# CSV.open('top_movies_data.csv','w') do |csv|
#   csv << ['movie','link','region','date','views']
# end

# movies.each do |m|
#   next if movies.find { |n| n['link'] == m['link'] && n['region'] != m['region'] && n['views']}

#   data = get_page_views(page: m['link'].split('/').last, from: '2018010100', to: '2018123100')
#   m['views'] = {}
#   next unless data

#   data.each do |d|
#     days[d['timestamp']] = DateTime.parse(d['timestamp']).to_date.to_s unless days[d['timestamp']]
#     m['views'][d['timestamp']] = d['views']
#     CSV.open('top_movies_data.csv', 'a') do |csv|
#       csv << [m['name'], m['link'], m['region'], m['year'], d['timestamp'], d['views']]
#     end
#   end
# end

# CSV.open('top_movies_data.csv', 'w') do |csv|
#   CSV.read('top_movies_data_old.csv', headers: true).uniq.each { |r| csv << r }
# end

# exit

movies = {}
days = {}

puts 'loading the movie data'
movie_data = CSV.read('top_movies_data.csv', headers: true)

puts 'making a list of days'
movie_data.each do |m|
  days[m['date']] = DateTime.parse(m['date']).to_date.to_s unless days[m['date']]
end

puts 'making a list of movies'
movie_data.each do |m|
  movies[m['link']] = {'movie' => m['movie'], 'region' => m['region'], 'year' => m['year'], 'views' => {} } unless movies[m['link']]
end

# movies = movie_data.map {|m| {'movie' => m['movie'], 'region' => m['region'], 'year' => m['year'], 'views' => {} } }.uniq
# exit

puts 'putting the views into each movie'
movie_data.each do |m|
  movies[m['link']]['views'][m['date']] = m['views']
  # m['views'][v['date']] = v['views']
end

# puts 'putting the views into each movie'
# movies.each do |m|
#   m['views'] = {}
#   movie_data.select {|s| s['movie'] == m['movie']}.each do |v|
#     m['views'][v['date']] = v['views']
#   end
# end

puts 'making the actual csv'
CSV.open('top_movies.csv', 'wb') do |csv|
  csv << ['movie', 'region', 'year'] + days.values.sort
  movies.values.each_with_index do |m,j|
    print "#{j}/#{movies.keys.count}\r"
    tmp = [m['movie'], m['region'], m['year']]
    val = []
    days.keys.sort.each do |k|
      # puts k
      if m['views'][k]
        val << m['views'][k].to_i
      else
        val << 0
      end
      begin
        tmp << val.last(60).sum
        # tmp << val.sum
      rescue => e
        puts e
        p m
        p m['views']
        puts k
        exit
      end
    end
    csv << tmp
  end
end