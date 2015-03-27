class BaseName
  DEFAULT_THRESHOLD = 0.3

  attr_accessor :name,
    :to_match_names,
    :matching_methods,
    :soundex

  def initialize(params = {})
    @name             = params.fetch(:name)
    @soundex          = Text::Soundex.soundex(@name)
    @matching_methods = params.fetch(:matching_methods)
    threshold         = params.fetch(:threshold)
    @to_match_names   = params.fetch(:to_match_names)

    @to_match_names = @to_match_names.map do |tmn|
      ToMatchName.new(
        :name      => tmn,
        :base_name => self
      )
    end.keep_if do |tmn|
      tmn.score >= threshold
    end.sort
  end
end

class ToMatchName
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
    @scores    = []

    if @base_name.matching_methods.present?
      matched_methods = MatchingMethod.descendants.select do |mm|
        @base_name.matching_methods.include?(mm.to_s)
      end

      @scores = matched_methods.map do |mm|
        mm.new(
          :name      => @name,
          :base_name => @base_name
        )
      end

      @score = @scores.inject(0.0){|sum, s| sum + s.score }
      @score = (@score / @scores.size).round(3)
    end
  end

  def <=>(another)
    another.score <=> score
  end
end
