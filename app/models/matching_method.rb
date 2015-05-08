class MatchingMethod
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

  def soundex_distance(s1, s2)
    if s1.first != s2.first
      s1.size  # Different category, so they suppose to be completely different
    else
      Text::Levenshtein.distance(s1[1..3], s2[1..3])
    end
  end
end

class LookupTable < MatchingMethod
  WEIGHT = 10

  private

  def cal_score
    base = LookupTableRecord.where(:name => @base_name.name)
    @score = if base.nil?
               0
             else
               base = base.map(&:ref)
               refs = LookupTableRecord.where(:ref => base, :name => @name)

               if refs.present?
                 @label = (base & refs.map(&:ref)).join(', ')
                 @value = "Matched"
                 1
               else
                 0
               end
             end
  end
end

class LevenshteinDistance < MatchingMethod
  private

  def cal_score
    @value = Text::Levenshtein.distance(@name, @base_name.name)
    size   = [@name.size, @base_name.name.size].max
    @score = ((size - @value).to_f / size)
  end
end

class Soundex < MatchingMethod
  WEIGHT = 3

  def self.soundex(name)
    result = name.first

    name[1..name.length].split('').each do |n|
      result = result + category(n).to_s
    end

    # Remove double chatacters
    result.gsub!(/([0-9])\1+/, '\1')

    # If category of 1st letter equals 2nd character, remove 2nd character
    if result.size >= 2 && category(result[0]).to_s == result[1]
      result.slice!(1)
    end

    # Remove slashes
    result.gsub!(/\//, '')

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
    if c.match(/[AEIOUY]/).present?
      "/"
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
    name_soundex      = Soundex.soundex(@name)
    base_name_soundex = Soundex.soundex(@base_name.name)

    @value = "#{name_soundex} <=> #{base_name_soundex}"
    s_dis  = soundex_distance(name_soundex, base_name_soundex)
    @score = ((@value.size - s_dis).to_f / @value.size)
  end
end

class IrishSoundex < MatchingMethod
  WEIGHT = 6

  def self.soundex(name)
    name = name.match(/^ST./).present? ? "SAINT #{name[3..name.length]}" : name

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

    name = name.strip.gsub(/^C/, 'K')
    @label = name
    Soundex.soundex(name)
  end

  private

  def cal_score
    name_soundex      = IrishSoundex.soundex(@name)
    base_name_soundex = IrishSoundex.soundex(@base_name.name)

    @value = "#{name_soundex} <=> #{base_name_soundex}"
    s_dis  = soundex_distance(name_soundex, base_name_soundex)
    @score = ((@value.size - s_dis).to_f / @value.size)
  end
end
