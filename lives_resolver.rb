require 'factual'
require 'mongo'
require 'pry'
require 'csv'

class LivesResolver

  include Mongo
  # Set up (or re-establish connection to) data store
  @@mongo_client = MongoClient.new("localhost", 27017)
  @@db = @@mongo_client.db("factual-test")
  @@coll = @@db["factual-data-2"]

  def resolve_csv(file_path)
    factual = Factual.new(ENV["FACTUAL_KEY"], ENV["FACTUAL_SECRET"], debug: false)
    counter = 1
    CSV.foreach(file_path, :headers => :true) do |row|
      if @@coll.find("id"=>row["id"]).to_a.count == 0
        hash_input = { name: row["name"], address: row["address1"], locality: "San Francisco", region: "CA", postcode: row["zip"] }
        lives_id = row["id"]
        begin
          query = factual.resolve(hash_input)
          factual_response = query.first
          if query.first == nil
            p "#{counter}: nil response from Factual"
            #binding.pry
          else
            p "#{counter}: hit!"
          end
        rescue Timeout::Error
          p "#{counter} Timeout Error"
          factual_response = "factual-timeout"
        end
        insert_hash = { id: lives_id, lives_data: hash_input, factual_data: factual_response }
        test_insert = @@coll.insert(insert_hash)
      else
        p "#{counter} skipping -- already done (or to be skipped)"
      end
      counter += 1
    end
  end

  def output_unmatched_to_json(input_csv_path, output_csv_path)
    opened_file = File.open(input_csv_path) { |f| f.read }
    parsed_lives_data = CSV.parse opened_file, headers: true

    # For each restaurant in CSV without Factual data in Mongo, create a JSON object with LIVES data and Yelp ID
    output_data = Array.new
    output_data[0] = parsed_lives_data.headers
    parsed_lives_data.each do |lives_csv_row|
      mongo_result = @@coll.find("id"=>lives_csv_row["id"]).first
      if mongo_result["factual_data"] == nil or mongo_result["factual_data"] == "factual-timeout"
        output_data << lives_csv_row
      end
    end
    CSV.open(output_csv_path, "w") do |output_csv_object|
      output_data.each do |data_row|
        output_csv_object << data_row
      end
    end
  end

end


#LivesResolver.resolve_csv("./lives-sf.csv")

#l = LivesResolver.new
#l.output_unmatched_to_json("./lives-sf.csv", "./unmatched-LIVES-SF-restaurants.csv")



