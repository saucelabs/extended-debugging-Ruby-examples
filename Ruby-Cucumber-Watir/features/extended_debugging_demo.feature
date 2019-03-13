Feature: Performance Testing
    Check webpage performance

    Scenario: Extended debugging cucumber-watir demo
      Given I am on the Login Page
      When I log in with valid credentials
      Then I should be logged in
      Given I am on the Product Page
      Then I assert the sauce:performance custom command identifies page load regressions
      Then I assert the sauce:performance custom command identifies speedIndex regressions
