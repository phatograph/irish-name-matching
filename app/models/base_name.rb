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

    @to_match_names  = params.fetch(:to_match_names).map do |tmn|
      ToMatchedName.new(
        :name => tmn,
        :matched_name => self
      )
    end.keep_if do |tmn|
      tmn.score >= threshold
    end.sort
  end
end

class ToMatchedName
  include Comparable

  attr_accessor :name,
    :matched_name,
    :soundex,
    :ld,
    :score,
    :scores

  def initialize(params = {})
    @name         = params.fetch(:name)
    @matched_name = params.fetch(:matched_name)
    @scores       = []

    if @matched_name.matching_methods.present?
      matched_methods = MatchedMethod.descendants.select do |mm|
        @matched_name.matching_methods.include?(mm.to_s)
      end

      @scores = matched_methods.map do |mm|
        mm.new(
          :name         => @name,
          :matched_name => @matched_name
        )
      end

      @score = (@scores.inject(0.0) {|sum, s| sum + s.score } / @scores.size).round(3)
    end
  end

  def <=>(another)
    another.score <=> score
  end
end
