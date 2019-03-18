Before do |scenario|
  @feature_name = scenario.feature.name
end

Given(/^I am on the Login Page$/) do
  @driver.get "http://www.saucedemo.com"
end

When(/^I log in with valid credentials$/) do
  username = ENV["PERF_USERNAME"] ||= "standard_user"
  @driver.find_element(css: "[data-test=username]").send_keys username
  @driver.find_element(css: "[data-test=password]").send_keys "secret_sauce"
  @driver.find_element(css: "[type=submit]").click
end

When(/^I log in as a performance regression user$/) do
  @driver.find_element(css: "[data-test=username]").send_keys"performance_glitch_user"
  @driver.find_element(css: "[data-test=password]").send_keys "secret_sauce"
  @driver.find_element(css: "[type=submit]").click
end

Then(/^I should be logged in$/) do
  expect(@driver.current_url).to eq "https://www.saucedemo.com/inventory.html"
end

Given(/^I am on the Product Page$/) do
  @driver.get  "https://www.saucedemo.com/inventory.html"
end

Then(/^I check for sauce:performanceLogs/) do
  metrics = ["load", "speedIndex", "pageWeight", "pageWeightEncoded", "timeToFirstByte",
             "timeToFirstInteractive", "firstContentfulPaint", "perceptualSpeedIndex", "domContentLoaded"]
  performance = @driver.execute_script("sauce:log", {"type": "sauce:performance"})
  metrics.each do |metric|
    expect(performance["speedIndex"] < 1000).to be true
  end
end

Then(/^I assert the sauce:performance custom command identifies page load regressions/) do
  performance = @driver.execute_script("sauce:performance", {"name":@feature_name, "metrics": ["load"] })
  # The custom command will return "pass" if the test falls within the predicted baseline
  # or "fail"  if the performance metric falls outside the predicted baseline.
  # customers can decide how strict they want to be in failing tests by setting thier own
  # failure points.
  performance["result"] != "pass" ?
    (expect(performance["details"]["load"] < 5000).to be true) :
    (expect(performance["result"] == "pass").to be true)
end

Then(/^I assert the sauce:performance custom command identifies speedIndex regressions/) do
  performance = @driver.execute_script("sauce:performance", {"name":@feature_name, "metrics": ["timeToFirstInteractive"] })
  performance["result"] != "pass" ?
    (expect(performance["details"]["timeToFirstInteractive"] < 5000).to be true) :
    (expect(performance["result"] == "pass").to be true)
end
