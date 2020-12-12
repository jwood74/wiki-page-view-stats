require_relative 'commands'

pages = [
  { name: 'Donald Trump', page: 'Donald_Trump' },
  { name: 'Joe Biden', page: 'Joe_Biden' }
]

days = {}

pages.each do |pg|
  data = get_page_views(page: pg[:page], from: '2020010100', to: '2020111000')
  data.items.each do |d|
    days[d['timestamp']] = { 'date' => DateTime.parse(d['timestamp']).to_date.to_s } unless days[d['timestamp']]
    days[d['timestamp']][pg[:page]] = d['views']
  end
end

CSV.open('us_election.csv', 'wb') do |csv|
  csv << days.values[0].keys
  days.values.each do |hash|
    csv << hash.values
  end
end
