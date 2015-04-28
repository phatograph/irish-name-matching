module ApplicationHelper
  def has_mm?(matching_methods, mm)
    matching_methods && matching_methods.map{|x| x[:name] }.include?(mm.to_s)
  end
end
