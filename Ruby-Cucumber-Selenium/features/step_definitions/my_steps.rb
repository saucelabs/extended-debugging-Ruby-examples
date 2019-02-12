Before do |scenario|
  @feature_name = scenario.feature.name
end

Given(/^I am on the Login Page$/) do
  @driver.get 'http://www.saucedemo.com'
end

Given(/^I am on the Product Page$/) do
  @driver.get 'http://www.saucedemo.com/inventory.html'
end

When(/^I log in with valid credentials$/) do
  username = ENV['PERF_USERNAME'] ||= 'standard_user'
  @driver.find_element(css: "[data-test=username]").send_keys username
  @driver.find_element(css: "[data-test=password]").send_keys 'secret_sauce'
  @driver.find_element(css: "[type=submit]").click
end

When(/^I log in as a performance regression user$/) do
  @driver.find_element(css: "[data-test=username]").send_keys'performance_glitch_user'
  @driver.find_element(css: "[data-test=password]").send_keys 'secret_sauce'
  @driver.find_element(css: "[type=submit]").click
end

Then(/^I should be logged in$/) do
  expect(@driver.current_url).to eq 'https://www.saucedemo.com/inventory.html'
end

Then(/^I should go to the inventory page$/) do 
  @driver.get  "https://www.saucedemo.com/inventory.html"
end

Then(/^I check for sauce:network logs/) do
  network = @driver.execute_script("sauce:log", {"type": "sauce:network"})
  is_request_exists = false
  network.each do |req|
    if req['url'].include? "main.js"
      is_request_exists = true
    end
  end
  expect(is_request_exists).to be true
end

Then(/^I check for sauce:metrics logs/) do
  metrics = @driver.execute_script("sauce:log", {"type": "sauce:metrics"})
  pageLoadTime = metrics['domContentLoaded'] - metrics['navigationStart']
  expect(pageLoadTime <=5).to be true
end

Then(/^I check for sauce:timing logs/) do
  timing = @driver.execute_script("sauce:log", {"type": "sauce:timing"})
  expect(timing.include? "domLoading")
end

Then(/^I check for sauce:performanceLogs/) do
  metrics = ["load", "speedIndex", "pageWeight", "pageWeightEncoded", "timeToFirstByte",
             "timeToFirstInteractive", "firstContentfulPaint", "perceptualSpeedIndex", "domContentLoaded"]
  performance = @driver.execute_script("sauce:log", {"type": "sauce:performance"})
  metrics.each do |metric|
    expect(performance.include? metric).to be true
  end
end

Then(/^I assert the sauce:performance custom command identifies regressions/) do
  performance = @driver.execute_script("sauce:performance", {"name":@feature_name, "metrics": ["load"] })
  expect(performance).to be true
end
