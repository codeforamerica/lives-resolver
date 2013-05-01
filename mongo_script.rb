
require 'mongo'
require 'pry'

include Mongo

# Set up (or re-establish connection to) data store
mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("factual-test")
coll = db["factual-data-2"]

puts "#{coll.find('factual_data.resolved'=>true).count} resolved"
puts "#{coll.find("factual_data"=>"factual-timeout").count} timed out"
puts "#{coll.find("factual_data"=>nil).count} unresolved"

binding.pry

