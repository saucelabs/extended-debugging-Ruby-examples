Feature: Authentication
  
  Scenario: Login Successful
    Given I am on the Login Page
    When I log in with valid credentials
    Then I should be logged in
