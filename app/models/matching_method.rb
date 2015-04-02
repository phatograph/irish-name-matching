class MatchingMethod
  attr_accessor :name,
    :base_name,
    :value,
    :score

  def initialize(params = {})
    @name      = params.fetch(:name)
    @base_name = params.fetch(:base_name)
    cal_score
  end

  def get_score
    @score.round(3)
  end

  private

  def cal_score
    raise NotImplementedError
  end
end

class LD < MatchingMethod
  private

  def cal_score
    @value = Text::Levenshtein.distance(@name, @base_name.name)
    size   = [@name.size, @base_name.name.size].max
    @score = ((size - @value).to_f / size)
  end
end

class Soundex < MatchingMethod
  private

  def cal_score
    @value           = Text::Soundex.soundex(@name)
    soundex_distance = Text::Levenshtein.distance(@value, @base_name.soundex)
    size             = [@value.size, @base_name.soundex.size].max
    @score           = ((size - soundex_distance).to_f / size)
  end
end
