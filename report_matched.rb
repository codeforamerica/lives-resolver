require 'mongo'
require 'json'


class MatchReporter

  include Mongo

  def initialize
    @mongo_client = MongoClient.new("localhost", 27017)
    @db = @mongo_client.db(@results_db)
    @coll = @db[@results_coll]
  end

  def create_reports
    puts @db
    results_fields = %w(name address locality region postcode)

    matched_filename = @results_db + "." + @results_coll + "." + "matched.txt"
    unmatched_filename = @results_db + "." + @results_coll + "." + "unmatched.txt"
    File.open(matched_filename, "w") do |matched|
      File.open(unmatched_filename, "w") do |unmatched|
        @coll.find().each do |record|
          puts record
          results_row_array = [record['id']]
          results_fields.each do |field_name|
            results_row_array.push(record['lives_data'][field_name])
          end
          if record['factual_data'].nil?
            unmatched.write(results_row_array.join("\t"))
            unmatched.write("\n")
          else
            results_row_array.push(record['factual_data']['factual_id'])
            matched.write(results_row_array.join("\t"))
            matched.write("\n")
          end
        end
      end
    end
  end

end

class SFMatchReporter < MatchReporter
  def initialize
    @results_db = "factual-test"
    @results_coll = "factual-data-sf-2"
    super
  end
end

reporter = SFMatchReporter.new
reporter.create_reports
