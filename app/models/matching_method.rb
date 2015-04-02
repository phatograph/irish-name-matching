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

Dir['app/models/matching_method/*.rb'].each do |f|
   require Pathname.new(f).realpath
end
