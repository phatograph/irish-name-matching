class BaseName
  DEFAULT_THRESHOLD = 0

  attr_accessor :name,
    :to_match_names,
    :matching_algorithms

  def initialize(params = {})
    MatchingAlgorithm  # Hack to load up MatchingAlgorithm subclasses

    @name                = params.fetch(:name)
    @matching_algorithms = params.fetch(:matching_algorithms)
    @to_match_names      = params.fetch(:to_match_names)
    threshold            = params.fetch(:threshold) || DEFAULT_THRESHOLD

    @to_match_names = @to_match_names.map do |tmn|
      puts "Processing for #{@name}: #{tmn}"
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
    :score,
    :scores

  def initialize(params = {})
    @name      = params.fetch(:name)
    @base_name = params.fetch(:base_name)
    @score     = 0
    @scores    = []

    if @base_name.matching_algorithms.present?
      MatchingAlgorithm  # Hack to load up MatchingAlgorithm subclasses

      @scores = @base_name.matching_algorithms.map do |mm|
        mm[:name].constantize.new(
          :name      => @name,
          :base_name => @base_name,
          :weight    => mm[:weight].to_i
        )
      end

      @score = @scores.inject(0.0){|sum, s| sum + s.score * s.weight }
      @score = (@score / @scores.inject(0.0){|sum, s| sum + s.weight}).round(3)
    end
  end

  def <=>(another)
    another.score <=> score
  end
end
