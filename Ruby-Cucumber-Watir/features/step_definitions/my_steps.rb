Before do |scenario|
  @feature_name = scenario.feature.name
end

Given(/^I am on the Login Page$/) do
  @browser.goto 'www.saucedemo.com'
end

Given(/^I am on the Product Page$/) do
  @browser.goto 'www.saucedemo.com/inventory.html'
end

When(/^I log in with valid credentials$/) do
  username = ENV['PERF_USERNAME'] ||= 'standard_user'
  @browser.text_field(data_test: 'username').set username
  @browser.text_field(data_test: 'password').set 'secret_sauce'
  @browser.button(type: 'submit').click
end

When(/^I log in as a performance regression user$/) do
  @browser.text_field(data_test: 'username').set 'performance_glitch_user'
  @browser.text_field(data_test: 'password').set 'secret_sauce'
  @browser.button(type: 'submit').click
end

Then(/^I should be logged in$/) do
  expect(@browser.url).to eq 'https://www.saucedemo.com/inventory.html'
end

Then(/^I should go to the inventory page$/) do 
  @browser.goto  "https://www.saucedemo.com/inventory.html"
end

Then(/^I check for sauce:network logs/) do
  network = @browser.execute_script("sauce:log", {"type": "sauce:network"})
  is_request_exists = false
  network.each do |req|
    if req['url'].include? "main.js"
      is_request_exists = true
    end
  end
  expect(is_request_exists).to be true
end

Then(/^I check for sauce:metrics logs/) do
  metrics = @browser.execute_script("sauce:log", {"type": "sauce:metrics"})
  pageLoadTime = metrics['domContentLoaded'] - metrics['navigationStart']
  expect(pageLoadTime <=5).to be true
end

Then(/^I check for sauce:timing logs/) do
  timing = @browser.execute_script("sauce:log", {"type": "sauce:timing"})
  expect(timing.include? "domLoading")
end

Then(/^I check for sauce:performanceLogs/) do
  metrics = ["load", "speedIndex", "pageWeight", "pageWeightEncoded", "timeToFirstByte",
             "timeToFirstInteractive", "firstContentfulPaint", "perceptualSpeedIndex", "domContentLoaded"]
  performance = @browser.execute_script("sauce:log", {"type": "sauce:performance"})
  metrics.each do |metric|
    expect(performance.include? metric).to be true
  end
end

Then(/^I assert the sauce:performance custom command identifies regressions/) do
  performance = @browser.execute_script("sauce:performance", {"name":@feature_name, "metrics": ["load"] })
  expect(performance).to be true
end
