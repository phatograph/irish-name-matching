json.array! @matched_names do |matched_name|
  json.name matched_name.name
  json.soundex matched_name.soundex

  json.to_match_names do
    json.array! matched_name.to_match_names do |tmn|
      json.name tmn.name
      json.soundex tmn.soundex
      json.score tmn.score

      json.scores do
        json.array! tmn.scores do |s|
          json.method s.class.name
          json.value s.value
          json.score s.score
        end
      end
    end
  end
end
