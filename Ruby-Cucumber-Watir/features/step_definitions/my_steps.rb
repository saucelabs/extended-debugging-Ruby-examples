Before do |scenario|
  @feature_name = scenario.feature.name
end

Given(/^I am on the Login Page$/) do
  @browser.goto "www.saucedemo.com"
end

Given(/^I am on the Product Page$/) do
  @browser.goto "www.saucedemo.com/inventory.html"
end

When(/^I log in with valid credentials$/) do
  username = ENV["PERF_USERNAME"] ||= "standard_user"
  @browser.text_field(data_test: "username").set username
  @browser.text_field(data_test: "password").set "secret_sauce"
  @browser.button(type: "submit").click
end

When(/^I log in as a performance regression user$/) do
  @browser.text_field(data_test: "username").set "performance_glitch_user"
  @browser.text_field(data_test: "password").set "secret_sauce"
  @browser.button(type: "submit").click
end

Then(/^I should be logged in$/) do
  expect(@browser.url).to eq "https://www.saucedemo.com/inventory.html"
end

Then(/^I check for sauce:performanceLogs/) do
  metrics = ["load", "speedIndex", "pageWeight", "pageWeightEncoded", "timeToFirstByte",
             "timeToFirstInteractive", "firstContentfulPaint", "perceptualSpeedIndex", "domContentLoaded"]
  performance = @browser.execute_script("sauce:log", {"type": "sauce:performance"})
  metrics.each do |metric|
    expect(performance.include? metric).to be true
  end
end

Then(/^I assert the sauce:performance custom command identifies page load regressions/) do
  performance = @browser.execute_script("sauce:performance", {"name":@feature_name, "metrics": ["load"] })
  # The custom command will return "pass" if the test falls within the predicted baseline
  # or "fail"  if the performance metric falls outside the predicted baseline.
  # customers can decide how strict they want to be in failing tests by setting thier own
  # failure points.
  performance["result"] != "pass" ? 
    (expect(performance["details"]["load"]["actual"] < 5000).to be true) :
    (expect(performance["result"] == "pass").to be true)
end

Then(/^I assert the sauce:performance custom command identifies speedIndex regressions/) do
  performance = @browser.execute_script("sauce:performance", {"name":@feature_name, "metrics": ["timeToFirstInteractive"] })
  performance["result"] != "pass" ? 
    (expect(performance["details"]["timeToFirstInteractive"]["actual"] < 5000).to be true) :
    (expect(performance["result"] == "pass").to be true)
end
