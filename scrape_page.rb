require_relative 'commands'

# This is the folder for the project
# It will create a input.csv in that project
folder = get_input('Which folder?', ARGV[0])

# This is a directory page containing link to sub pages
# Eg. https://en.wikipedia.org/wiki/2020_in_video_games
website = get_input('What site?', ARGV[1])

# This is the XPath for the subpages
# Eg. //*[@id="mw-content-text"]/div[1]/table[tbody/tr/th[3]="Title"]/tbody/tr/td/i/a
item_code = get_input('Xpath to items?', ARGV[2])

scrape_page_for_items(folder, website, item_code)

# The method will then find the subpages using the provided XPath and save to the CSV.
# The general `run` program can then be run like normal. It will be able to skip the step of looking up page names.