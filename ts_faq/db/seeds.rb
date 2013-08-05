# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


require "csv"

CSV.foreach('db/items.csv') do |row|
Item.create(:id => row[0],
            :name => row[1],
            :update_user => row[2])
end 

require "csv"

CSV.foreach('db/cases.csv') do |row|
Case.create(:id => row[0],
            :item_id => row[1],
            :name => row[2])
end 

require "csv"

CSV.foreach('db/procedures.csv') do |row|
Procedure.create(:id => row[0],
                 :case_id => row[1],
                 :name => row[2],
                 :reference => row[3])
end 
