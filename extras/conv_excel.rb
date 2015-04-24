# Converting excel tabized input to a seed input for rails

text = File.open('./input.txt').read
result = ''

text.each_line do |l|
  ls = l.split("\t")
  name = ls.shift

  ls.each do |w|
    result += "LookupTableRecord.create(:name => \"#{name.upcase}\", :ref => #{w.gsub(/[\r\n]/, '')})\n"
  end
end

puts result
File.open('./output.txt', 'w') { |file| file.write(result) }
