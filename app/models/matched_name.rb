class MatchedName
  attr_accessor :name, :to_match_names, :matching_method

  def initialize(params = {})
    @name            = params.fetch(:name)
    @to_match_names  = params.fetch(:to_match_names)
    @matching_method = params.fetch(:matching_method)
  end
end
