require 'test_helper'
require 'rails/performance_test_help'

class MatchTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }

  self.profile_options = { :runs => 1 }

  test "matching names" do
    post '/match',
      "base_names" => 'Smith',
      "to_match_names" => '',
      "threshold" =>"0",
      "standard_list" => "true",
      "matching_algorithms" => {
        # "LevenshteinDistance" => {
        #   "name"=>"LevenshteinDistance",
        #   "weight"=>"1"
        # },
        # "Soundex" => {
        #   "name"=>"Soundex",
        #   "weight"=>"3"
        # },
        # "IrishSoundex" => {
        #   "name" => "IrishSoundex",
        #   "weight"=>"6"
        # },
        "LookupTable" => {
          "name"=>"LookupTable",
          "weight"=>"10"
        }
      }
  end
end
