class MatchingMethod::Soundex < MatchingMethod
  private

  def cal_score
    @value           = Text::Soundex.soundex(@name)
    soundex_distance = Text::Levenshtein.distance(@value, @base_name.soundex)
    size             = [@value.size, @base_name.soundex.size].max
    @score           = ((size - soundex_distance).to_f / size)
    @score = 1
  end
end
