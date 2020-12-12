require_relative 'commands'

if ARGV[0]
  folder = ARGV[0]
else
  puts 'which folder?'
  folder = gets.chomp
end

puts 'Getting list of pages from '
input = CSV.read("#{folder}/input.csv", headers: true)

pages = get_page_names(input)

dump_pages_to_csv(pages, folder)

if ARGV[1]
  from = ARGV[1]
else
  puts 'from when?'
  from = gets.chomp
end

if ARGV[2]
  to = ARGV[2]
else
  puts 'to when?'
  to = gets.chomp
end

page_views = get_view_data(pages, from, to)

dump_page_views_to_csv(page_views, folder)

reformat_page_views(page_views, folder, 'cumulative')
