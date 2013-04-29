require 'factual'
require 'mongo'
require 'pry'
require 'csv'

include Mongo

mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("factual-test")
coll = db["factual-data"]

factual = Factual.new(ENV["FACTUAL_KEY"], ENV["FACTUAL_SECRET"], debug: true)

counter = 1

ids_to_skip = ["70014"]

CSV.foreach("./lives-sf.csv", :headers => :true) do |row|
  if coll.find("id"=>row["id"]).to_a.count == 0 && !ids_to_skip.include?(row["id"])
    hash_input = { name: row["name"], address: row["address1"], region: "CA", postcode: row["zip"] }
    lives_id = row["id"]
    #binding.pry
    query = factual.resolve(hash_input)
    insert_hash = { id: lives_id, lives_data: hash_input, factual_data: query.first }
    test_insert = coll.insert(insert_hash)
    if query.first == nil
      p "#{counter}: nil response from Factual"
    else
      p "#{counter}: hit!"
    end
  else
    p "#{counter} skipping -- already done (or to be skipped)"
  end
  counter += 1
end

#example_lives_id = "2704"
#example_hash_input = { name: "JUDY'S CAFE" , address: "2268 CHESTNUT ST", region: "CA", postcode: "94123" }
#example_lives_id = "testbaddata"
#example_hash_input = { name: "Super fake name really", address: "123 Fake Street", region: "CA", postcode: "94123" }

binding.pry

