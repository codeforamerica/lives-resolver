require 'factual'
require 'mongo'
require 'pry'
require 'csv'



# Need to make Mongo connection info args & initialized
class LivesResolver

  include Mongo

  def initialize()
    # Set up (or re-establish connection to) data store
    @@mongo_client = MongoClient.new("localhost", 27017)
    @@db = @@mongo_client.db(@mongo_db_name)
    @@coll = @@db[@mongo_coll_name]
  end

  def resolve_csv(file_path)
    factual = Factual.new(ENV["FACTUAL_KEY"], ENV["FACTUAL_SECRET"], debug: false)
    counter = 1
    last_id = nil
    CSV.foreach(file_path, :headers => :true) do |row|
      if ((row[@local_id_field] != last_id) && (@@coll.find("id"=>row[@local_id_field]).to_a.count == 0))
        name_array = []
        @name_fields.each do |name_field|
          name_array.push(row[name_field])
        end
        name = name_array.join(" ")
        hash_input = {  name: name, 
                        address: row[@address_field], 
                        locality: row[@locality_field] || @locality_default, 
                        region: row[@region_field] || @region_default, 
                        postcode: row[@postcode_field] }
        lives_id = row[@local_id_field]
        begin
          query = factual.resolve(hash_input)
          factual_response = query.first
          if query.first == nil
            puts "#{counter}: nil response from Factual"
            #binding.pry
          else
            puts "#{counter}: hit!"
          end
        rescue Timeout::Error
          puts "#{counter} Timeout Error"
          factual_response = "factual-timeout"
        end
        insert_hash = { id: lives_id, lives_data: hash_input, factual_data: factual_response }
        test_insert = @@coll.insert(insert_hash)
      else
        puts "#{counter} skipping -- already done (or to be skipped)"
      end
      counter += 1
      last_id = row[@local_id_field]
    end
  end

  def output_unmatched_to_json(input_csv_path, output_csv_path)
    opened_file = File.open(input_csv_path) { |f| f.read }
    parsed_lives_data = CSV.parse opened_file, headers: true

    # For each restaurant in CSV without Factual data in Mongo, save to output csv 
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

class KingCountyLivesResolver < LivesResolver
  def initialize()
    @local_id_field = "Business_ID"
    @name_fields = ["Program Identifier"]
    @address_field = "Address"
    @locality_field = "City"
    @region_field = "State"
    @region_default = "WA"
    @postcode_field = "Zip Code"
    @mongo_db_name = "factual-test"
    @mongo_coll_name = "factual-data-king-program-identifier"
    super
  end
end

class SFLivesResolver < LivesResolver
  def initialize()
    @local_id_field = "id"
    @name_fields = ["name"]
    @address_field = "address1"
    @locality_field = "" # SF data doesn't have this field, so supply a default
    @locality_default = "San Francisco"
    @region_field = "" # SF data doesn't have this field, so supply a default
    @region_default = "CA"
    @postcode_field = "zip"
    @mongo_db_name = "factual-test"
    @mongo_coll_name = "factual-data-sf-2"
    super
  end
end

lr = KingCountyLivesResolver.new
lr.resolve_csv("king_county/Food_Establishment_Inspection_Data.csv")

#l = LivesResolver.new
#l.output_unmatched_to_json("./lives-sf.csv", "./unmatched-LIVES-SF-restaurants.csv")



