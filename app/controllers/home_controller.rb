class HomeController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:match]

  def index
    params[:matching_algorithms] = MatchingAlgorithm.descendants.map do |mm|
      {
        :name   => mm.to_s,
        :weight => mm::WEIGHT
      }
    end
  end

  def match
    base_names     = params[:file1].present? ? params[:file1].read : params[:base_names]
    to_match_names = params[:file2].present? ? params[:file2].read : params[:to_match_names]
    to_match_names = to_match_names.lines.map {|x| x.strip.upcase }

    if %w{true t 1}.include? params[:standard_list]
      to_match_names = LookupTableRecord.pluck(:name).uniq
    end

    params[:matching_algorithms] = params[:matching_algorithms] || ActionController::Parameters.new
    params[:matching_algorithms] = params[:matching_algorithms].
      to_a.
      select{|x| x.last[:name] }.  # Purge unchecked matching methods
      map do |x|
        {
          :name => x.last[:name],
          :weight => x.last[:weight]
        }
      end

    @matched_names = base_names.
      lines.
      map(&:strip).
      delete_if {|x| x.size.zero? }.
      map do |line|
        BaseName.new(
          :name                => line.upcase,
          :to_match_names      => to_match_names.delete_if {|x| x.size.zero? },
          :matching_algorithms => params[:matching_algorithms],
          :threshold           => params[:threshold].to_f
        )
      end

    render 'index'
  end
end
