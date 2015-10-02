Feature: Testing the test app
  Scenario: running rake in the test app
    When I cd to "../../multi-db-dummy"
    And I run `rake -T`
    Then the exit status should be 0
    And the output should match /rake db:create/