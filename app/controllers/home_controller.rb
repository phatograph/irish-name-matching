class HomeController < ApplicationController
  def index
    params[:matching_methods] = MatchedMethod.descendants.map(&:to_s)
  end

  def match
    file_content1 = params[:file1].present? ? params[:file1].read : params[:input1]
    file_content2 = params[:file2].present? ? params[:file2].read : params[:input2]
    file_content2 = file_content2.lines.map(&:strip)

    params[:matching_methods] = params[:matching_methods] || []

    @matched_names = file_content1.lines.map do |line|
      MatchedName.new(
        :name             => line.strip,
        :to_match_names   => file_content2,
        :matching_methods => params[:matching_methods],
        :threshold        => params[:threshold].to_f
      )
    end

    render 'index'
  end
end
