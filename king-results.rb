require 'mongo'
require 'json'

include Mongo

mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("factual-test")
coll = db["factual-data-king"]

results_fields = %w(name address locality region postcode)
                    
puts "id #{results_fields.join("\t")}"
coll.find('factual_data.resolved'=>true).each do |resolved|
  results_array = [resolved['id']]
  results_fields.each do |field_name|
    results_array.push(resolved['lives_data'][field_name])
  end
  puts results_array.join("\t")
  # puts resolved
end
