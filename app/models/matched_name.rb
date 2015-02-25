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
    :base_name,
    :soundex,
    :ld,
    :score,
    :scores

  def initialize(params = {})
    @name      = params.fetch(:name)
    @base_name = params.fetch(:base_name)

    @scores = MatchedMethod.descendants.map do |mm|
      mm.new(:name => @name, :base_name => @base_name)
    end

    @score = (@scores.inject(0.0) { |sum, el| sum + el.score } / @scores.size).round(3)
  end

  def <=>(another)
    another.score <=> score
  end
end

class MatchedMethod
  attr_accessor :name,
    :base_name,
    :value,
    :score

  def initialize(params = {})
    @name = params.fetch(:name)
    @base_name = params.fetch(:base_name)
    cal_score()
  end

  def get_score
    @score.round(3)
  end
end

class LD < MatchedMethod
  def cal_score
    @value = Text::Levenshtein.distance(@name, @base_name.name)
    size = [@name.size, @base_name.name.size].max
    @score = ((size - @value).to_f / size)
  end
end

class Soundex < MatchedMethod
  def cal_score
    @value = Text::Soundex.soundex(@name)
    soundex_distance = Text::Levenshtein.distance(@value, @base_name.soundex)
    size = [@value.size, @base_name.soundex.size].max
    @score = ((size - soundex_distance).to_f / size)
  end
end
