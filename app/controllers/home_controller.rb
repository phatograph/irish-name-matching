class HomeController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:match]

  def index
    params[:matching_methods] = MatchingMethod.descendants.map do |mm|
      {
        :name   => mm.to_s,
        :weight => mm::WEIGHT
      }
    end
  end

  def match
    file_content1 = params[:file1].present? ? params[:file1].read : params[:input1]
    file_content2 = params[:file2].present? ? params[:file2].read : params[:input2]
    file_content2 = file_content2.lines.map {|x| x.strip.upcase }

    if params[:standard_list].present?
      file_content2 = LookupTableRecord.pluck(:name).uniq
    end

    params[:matching_methods] = params[:matching_methods] || ActionController::Parameters.new
    params[:matching_methods] = params[:matching_methods].to_a.select{|x| x.last[:name] }
    params[:matching_methods] = params[:matching_methods].map{|x| {:name => x.first, :weight => x.last[:weight]} }

    @matched_names = file_content1.
      lines.
      map(&:strip).
      delete_if {|x| x.size.zero? }.
      map do |line|
        BaseName.new(
          :name             => line.upcase,
          :to_match_names   => file_content2.delete_if {|x| x.size.zero? },
          :matching_methods => params[:matching_methods],
          :threshold        => params[:threshold].to_f
        )
      end

    render 'index'
  end
end
