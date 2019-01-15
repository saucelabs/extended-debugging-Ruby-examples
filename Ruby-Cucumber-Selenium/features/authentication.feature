Feature: Authentication
  
  Scenario: Login Successful
    Given I am on the Login Page
    When I log in with valid credentials
    Then I should be logged in

  Scenario: Login Regression
    Given I am on the Login Page
    When I log in as a performance regression user
    Then I should go to the inventory page
    Then I should be logged in
    Then The regression test should fail