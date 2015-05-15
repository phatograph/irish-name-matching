json.array! @matched_names do |matched_name|
  json.name matched_name.name

  json.to_match_names do
    json.array! matched_name.to_match_names do |tmn|
      json.name tmn.name
      json.score tmn.score

      json.scores do
        json.array! tmn.scores do |s|
          json.method s.class.name
          json.value s.value
          json.label s.label
          json.score s.score
          json.weight s.weight
        end
      end
    end
  end
end
