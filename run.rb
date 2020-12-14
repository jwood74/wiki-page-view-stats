require_relative 'commands'

folder = get_input('Which folder?', ARGV[0])

input = CSV.read("#{folder}/input.csv", headers: true)

puts 'Fixing up the links'
fix_links(input)

create_json_for_pages(input, folder) unless File.exist?("#{folder}/#{folder}.json")

pages = load_json(folder)

puts 'Adding any new people'
add_new_people_to_json(pages, input)

update_json(pages, folder)

from = get_input('From which date? yyyymmdd', ARGV[1], 10)
to = get_input('To which date? yyyymmdd', ARGV[2], 10) unless from == 'skip'

puts 'Getting any new view data'
get_view_data(pages, from, to) unless from == 'skip'

update_json(pages, folder)

puts 'Updating the date list'
add_new_dates(pages)

update_json(pages, folder)

puts 'Exporting the views'
export_page_views(pages, folder)
