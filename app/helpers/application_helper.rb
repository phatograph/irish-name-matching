module ApplicationHelper
  def has_mm?(matching_algorithms, mm)
    matching_algorithms && matching_algorithms.map{|x| x[:name] }.include?(mm.to_s)
  end
end
