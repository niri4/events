# README
## Group Events

### New Features!
  - A group event will be created by an user.
  - The group event should run for a whole number of days e.g.. 30 or 60
  - There should be attributes to set and update the start, end and duration of the event and calculate the missing value if 2 are given
  - The event also has a name, description and location
  - Description supports formatting
  - The event should be draft or published
  - To publish all of the fields are required
  - it can be saved with only a subset of fields before it’s published
  - When the event is deleted/remove it should be kept in the database and marked as such.

### Deliverable:
- A group event will be created by an user.
- Write an AR model, spec and migration for a GroupEvent that would meet the needs of the description above
- Then write the api controller and spec to support JSON request/responses to manage these GroupEvents
- For the purposes of this exercise, ignore auth.
- Please provide your solution as a rails app called

### setup:
```
rails db:prepare
```

- to boot rails application server
 ```
 rails s
 ```

 - to run the testcases using rspec
  ```
  rspec
  ```
