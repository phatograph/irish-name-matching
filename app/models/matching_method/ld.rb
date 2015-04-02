class MatchingMethod::LD < MatchingMethod
  private

  def cal_score
    @value = Text::Levenshtein.distance(@name, @base_name.name)
    size   = [@name.size, @base_name.name.size].max
    @score = ((size - @value).to_f / size)
  end
end
