# wiki-page-view-stats

This project aims to retrieve page information and view stats for wikipedia pages.

It then formats this into a wide CSV for use in a bar chart race visulisation.

## TL;DR - Show me the graphs

- [Movies](https://public.flourish.studio/visualisation/4610425/)
- [The Royal Family](https://public.flourish.studio/visualisation/4634058/)

## Backstory

Wikipedia has a great [REST API](https://wikimedia.org/api/rest_v1/) to retreive various stats from across Wikipedia projects.

I recently also stumbled across [Flourish](https://flourish.studio/examples/) which offers some great Data Visulastion tools. Provided you're happy for your data and reports to be public, the tool is free to use.

One which particularly stood out was the Bar Race Chart. It feels like this form of visualsing data has really taken off over the last 18 months.

So now I had access to a treasurer trove of data, and a great way to visualise it. The only thing left was to decide where to start.

## Movies

It didn't take long to decide to start with movies. Specifically, how many people viewed the wikipedia pages of movies released in 2019.

### Process

1. Find a list of movies released in 2019

Not too hard to find a [good page](https://en.wikipedia.org/wiki/List_of_American_films_of_2019).

Thankfully this page, and similar ones for [AUS](https://en.wikipedia.org/wiki/List_of_Australian_films_of_2019), [GBR / UK](https://en.wikipedia.org/wiki/List_of_British_films_of_2019) and [CAN](https://en.wikipedia.org/wiki/List_of_Canadian_films_of_2019), were all formatted well enough to scrape the movie list.

A little bit of [Nokogiri](https://nokogiri.org/tutorials/parsing_an_html_xml_document.html) and I had a really big list of movies.

2. Get the view stats for each page from Wiki API

I choose to get the daily views for each page and dump to a CSV.

Looping through the each page was simple enough, and [the API](https://wikimedia.org/api/rest_v1/#/Pageviews%20data/get_metrics_pageviews_per_article__project___access___agent___article___granularity___start___end_) kindly returned results for each day in my chosen time period in a handy JSON format.

3. Format the results for Flourish Bar Race Chart

The Bar Race Chart reads data in a specific, but logical way.

There's a row for each item (each movie), and a column for time increment (each day).

I initially tried simply reformatting the CSV into this format and uploaded it to Flourish. The problem was that daily views were just too jumpy.

Bar Race Charts probably work better when you're looking at a total or aggregated result. E.g Total phone sales by manufacturer, over time.

To help smooth this down, I aggregated the results to show views for the last 30 days.

Finding the number to use here is definitely a fine art. Too small, and it moves too quick to notice. Too big, and results will be overshadowed by massive performers.

I ended up adding 2018 and 2020 movies too. Proved a really good timeline as different movies came out.

The result - https://public.flourish.studio/visualisation/4610425/

## Royal Family

After showing off my first creation of Movies, I got the suggestion for the Royal Family.

Like movies, the results showed that viewship had a strong correlation to what was going on in the rest of the world.

### Process

1. Find a list of pages for the Royal Family

I quickly found [a page](https://en.wikipedia.org/wiki/British_royal_family) with the links I needed, but given the smaller number, and unreliable format, I simply copy pasted each to a new CSV.

2. Get the page name for each link

Given I only copied the links to each page, and not the page title, I needed to retreive the name for each page. I wrote some code to visit each page, and retreive the page title. This also meant I had generic code to use next time I did the exact same thing.

A little bit of [looping](https://github.com/jwood74/wiki-page-view-stats/blob/4059924692d5439e7df3d8d0682d3749b1e0a410/commands.rb#L123) and the aid of nokogiri, and I had the page title for each.

3. Restructure!

Up until this point, I had not really been saving anything along the way. I would save the final views to a CSV, but everytime I wanted to change something along the way, I had to repeat every single step.

I decided to save everything to a JSON file along the way. This way, once I had found all the page names, I didn't have to look them up again!

This was a signficant re-write, as I made it as generic as possible. The program now saves each project into its own folder. It's even capable of receving new pages in the input file, without having to start over everthing from scratch.

4. Get the view stats for each page from Wiki API

Using the same snippet of code from my Movies attempt, I loop through each page, and save the [daily views](https://github.com/jwood74/wiki-page-view-stats/blob/4059924692d5439e7df3d8d0682d3749b1e0a410/commands.rb#L22) to my new JSON file.

5. Format the results for Flourish Bar Race Chart

I was again able to use snippets from my Movies attempt, but [rewrote it](https://github.com/jwood74/wiki-page-view-stats/blob/4059924692d5439e7df3d8d0682d3749b1e0a410/commands.rb#L103) for my new generic JSON format.

Because I was now saving and loading my progress to a JSON file, I can instantly skip to this step, if none of the previous steps in my code have noticed a change (no new pages added, no additional dates required).

Finding the magic aggregation number was again a process of trial and error. I stuck with 30 for quite a while, but I found that it slightly too big - not able portray quick changes.

14 is where I have landed, i.e Each day, it shows the number of people who viewed the page in the previous 14 days. This number proved a nice balance between nothing moving haphazardly, but still moving as current issues affected viewership.

The result - https://public.flourish.studio/visualisation/4634058/

## Setup

- Install ruby
- Install required gems: `bundle install`
- Create a folder eg. plants
- Create a CSV in the folder called 'input.csv'
- Fill the CSV with links to wikipedia pages (with the header 'links')
- (Optional) Add extra columns/categories for each link
- `ruby run.rb`

## TODO

1. Create some tests. I'm pretty sure I have configured GitHub to run tests with each push, but I'm yet to do proper TDD.
2. Error Handling. Never been great at this, so should take the opportunity to both practice and start some new habits.
3. Different Aggregations. The aggregation is currently set in one of the methods. Would be better to have some input into what is done.

## Contributions

Happy for any and all suggestions. Feel free to do a Pull Request or submit an Issue.
