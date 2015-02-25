class MatchedName
  attr_accessor :name,
    :to_match_names,
    :matching_method,
    :soundex

  def initialize(params = {})
    @name            = params.fetch(:name)
    @soundex         = Text::Soundex.soundex(@name)
    @matching_method = params.fetch(:matching_method)

    @to_match_names  = params.fetch(:to_match_names).map do |tmn|
      ToMatchedName.new(
        :name => tmn,
        :base_name => self
      )
    end.sort
  end

end

class ToMatchedName
  include Comparable

  attr_accessor :name,
    :soundex,
    :ld,
    :score

  def initialize(params = {})
    @name    = params.fetch(:name)
    @soundex = Text::Soundex.soundex(@name)
    @ld      = Text::Levenshtein.distance(@name, params.fetch(:base_name).name)
    @score   = @ld
  end

  def <=>(another)
    score <=> another.score
  end
end
