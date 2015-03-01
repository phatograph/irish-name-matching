class HomeController < ApplicationController
  def index
  end

  def match
    input2 = params[:input2].lines.map(&:strip)
    @matched_names = params[:input1].lines.map do |line|
      MatchedName.new(
        :name            => line.strip,
        :to_match_names  => input2,
        :matching_method => params[:matching_method]
      )
    end

    uploaded_file = params[:file1]
    @file_content = uploaded_file.read if uploaded_file.present?

    render 'index'
  end
end
