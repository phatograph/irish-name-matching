class MatchingAlgorithm
  WEIGHT = 1

  attr_accessor :name,
    :base_name,
    :value,
    :label,
    :score,
    :weight,
    :weighted_score

  def initialize(params = {})
    @name      = params.fetch(:name)
    @base_name = params.fetch(:base_name)
    @weight    = params.fetch(:weight)

    cal_score
    @score = @score.round(3)
    @weighted_score = (@score * @weight).round(3)
  end

  private

  def cal_score
    raise NotImplementedError
  end

  def soundex_distance_score(s1, s2)
    if s1.first != s2.first
      0  # Different category, so they suppose to be completely different
    else
      (s1.size - Text::Levenshtein.distance(s1, s2).to_f ) / s1.size
    end
  end
end

class LevenshteinDistance < MatchingAlgorithm
  private

  def cal_score
    @value = Text::Levenshtein.distance(@name, @base_name.name)
    size   = [@name.size, @base_name.name.size].max
    @score = ((size - @value).to_f / size)
  end
end

class Soundex < MatchingAlgorithm
  WEIGHT = 3

  def self.soundex(name)
    # Take the first letter of a string.
    result = name.first

    # Encode remaining letters
    name[1..name.length].split('').each do |n|
      result = result + category(n).to_s
    end

    # Remove two adjacent same characters
    result.gsub!(/([0-9])\1+/, '\1')

    # If category of 1st letter equals 2nd character, remove 2nd character
    if result.size >= 2 && category(result[0]).to_s == result[1]
      result.slice!(1)
    end

    # Trim or pad with zeros as necessary
    result = if result.size == 4
               result
             elsif result.size > 4
               result[0..3]
             else
               result.ljust(4, '0')
             end
  end

  private

  def self.category(c)
    if c.match(/[AEIOUHWY]/).present?
      ""
    elsif c.match(/[BPFV]/).present?
      1
    elsif c.match(/[CSKGJQXZ]/).present?
      2
    elsif c.match(/[DT]/).present?
      3
    elsif c.match(/[L]/).present?
      4
    elsif c.match(/[MN]/).present?
      5
    elsif c.match(/[R]/).present?
      6
    else
      ""
    end
  end

  def cal_score
    name_soundex      = self.class.soundex(@name)
    base_name_soundex = self.class.soundex(@base_name.name)

    @value = "#{base_name_soundex} <=> #{name_soundex}"
    @score = soundex_distance_score(name_soundex, base_name_soundex)
  end
end

class IrishSoundex < MatchingAlgorithm
  WEIGHT = 6

  def self.soundex(name)
    # Change initial ST. to SAINT
    name = name.match(/^ST\./).present? ? "SAINT #{name[3..name.length]}" : name

    # Discard Irish prefixes
    name = if name.match(/^O /).present?
             name[1..name.length].gsub(' ', '')
           elsif name.match(/^O'/).present?
             name[2..name.length].gsub(' ', '')
           elsif name.match(/^MC/).present?
             name[2..name.length].gsub(' ', '')
           elsif name.match(/^M'/).present?
             name[2..name.length].gsub(' ', '')
           elsif name.match(/^MAC/).present? && name != 'MAC'
             name[3..name.length].gsub(' ', '')
           else
             name
           end

    # Change initial C to K
    name = name.strip.gsub(/^C/, 'K')

    # Call to traditional soundex.
    return {
      :label => name,
      :soundex => Soundex.soundex(name)
    }
  end

  private

  def cal_score
    name_soundex      = self.class.soundex(@name)
    base_name_soundex = self.class.soundex(@base_name.name)

    @value = "#{base_name_soundex[:soundex]} <=> #{name_soundex[:soundex]}"
    @label = name_soundex[:label]
    @score = soundex_distance_score(name_soundex[:soundex], base_name_soundex[:soundex])
  end
end

class LookupTable < MatchingAlgorithm
  WEIGHT = 10

  private

  def cal_score
    # Look for a reference for base name
    base = LookupTableRecord.where(:name => @base_name.name)

    @score = if base.nil?  # Could not find reference for base name, no matches
               0
             else
               # Find any reference that has 1) same name 2) same reference
               base = base.map(&:ref)
               refs = LookupTableRecord.where(:ref => base, :name => @name)

               if refs.present?
                 @label = (base & refs.map(&:ref)).join(', ')
                 @value = "Matched"
                 1
               else  # Could not find reference for matching name, no matches
                 0
               end
             end
  end
end
