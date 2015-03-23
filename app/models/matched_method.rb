class MatchedMethod
  attr_accessor :name,
    :matched_name,
    :value,
    :score

  def initialize(params = {})
    @name = params.fetch(:name)
    @matched_name = params.fetch(:matched_name)
    cal_score()
  end

  def get_score
    @score.round(3)
  end
end

class LD < MatchedMethod
  def cal_score
    @value = Text::Levenshtein.distance(@name, @matched_name.name)
    size = [@name.size, @matched_name.name.size].max
    @score = ((size - @value).to_f / size)
  end
end

class Soundex < MatchedMethod
  def cal_score
    @value = Text::Soundex.soundex(@name)
    soundex_distance = Text::Levenshtein.distance(@value, @matched_name.soundex)
    size = [@value.size, @matched_name.soundex.size].max
    @score = ((size - soundex_distance).to_f / size)
  end
end
