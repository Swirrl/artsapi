# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

test_user = User.create(
  email: 'jeff@example.com',
  password: 'password',
  name: 'Jeff Vader',
  ds_name_slug: 'artsapi-dev'
)