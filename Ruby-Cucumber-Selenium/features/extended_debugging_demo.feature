Feature: Is Performance captured?
    Check webpage performance

    Scenario: Extended debugging cucumber-watir demo
      Given I am on the Login Page
      When I log in with valid credentials
      Then I should be logged in
      Then I check for sauce:network logs
      Then I check for sauce:metrics logs
      Then I check for sauce:timing logs
      Then I check for sauce:performance logs