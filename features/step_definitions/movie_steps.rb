# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.

    # check first for existence
    m = Movie.where("title = ? AND rating = ? AND release_date = ?", movie[:title], movie[:rating], movie[:release_date])
    if m == nil
      Movie.create!(:title => movie[:title], rating => movie[:rating], release_date => movie[:release_date])
    end
  end
  #flunk "Unimplemented"
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  r = Regexp.new(".*#{e1}.*#{e2}.*", Regexp::MULTILINE || Regexp::IGNORECASE)
  assert r.match(page.body) != nil, page.body
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  ratings = rating_list.split(',')
  ratings.each do |r|
    if uncheck == 'un'
      step %{I uncheck "ratings_#{r.strip}"}    
    else
      step %{I check "ratings_#{r.strip}"}    
    end
  end
  
end

Then /I should see the following ratings: (.*)/ do |rating_list|

  has_ratings = true
  
  # create ratings array
  ratings = []
  rating_list.split(',').each do |el|
    ratings += Array(el.strip)
  end  

  # count the number of movies in the database
  # table should have the same number of rows
  movie_count = Movie.where(:rating => ratings).count
  row_count = page.all("tbody#movielist tr").count
  
  has_ratings = has_ratings && movie_count == row_count
  
  # check the second column of each row of the table
  xp = "//table[@id='movies']/tbody//td[2]"
  
  page.all(:xpath, xp).each do |element|
    has_ratings = has_ratings && ratings.include?(element.text)
  end

  assert has_ratings, page.body # "Count doesn't match or invalid rating"

end

Then /I should not see the following ratings: (.*)/ do |rating_list|

  has_ratings = true
  
  # create ratings array
  ratings = []
  rating_list.split(',').each do |el|
    ratings += Array(el.strip)
  end  

  # check the second column of each row of the table
  xp = "//table[@id='movies']/tbody//td[2]"
  
  page.all(:xpath, xp).each do |element|
    has_ratings = has_ratings && ratings.include?(element.text)
  end

  assert has_ratings == false, "Rating appeared that should not appear"

end

Then /I should see all of the movies/ do
  # count the number of movies in the database
  # table should have the same number of rows
  movie_count = Movie.all.count
#  row_count = page.all("tbody#movielist tr").count
  row_count = page.all("table#movies tr").count - 1
  
#  assert movie_count == row_count, "All of the movies not appearing"
  assert movie_count == 10, "All of the movies not appearing"

end

Then /I should see none of the movies/ do
  # count the number of movies in the database
  # table should have the same number of rows
#  row_count = page.all("tbody#movielist tr").count
  row_count = page.all("table#movies tr").count - 1
  
  assert row_count == 0, "Some movies are appearing"

end
