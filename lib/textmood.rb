#encoding: utf-8

if RUBY_VERSION < '1.9'
  $KCODE='u'
else
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

require "json"

NORMALIZE_TO = 100

class TextMood

  def initialize(options = {})
    options[:max_threshold] ||=  0.5
    options[:min_threshold] ||= -0.5
    options[:start_ngram]   ||=  1
    options[:end_ngram]     ||=  1
    @options = options
    if options[:language]
      if options[:alias_file]
        aliases = load_alias_file(options[:alias_file])
        if aliases
          file = aliases[options[:language]]
          unless file
            raise ArgumentError, "Language tag not found in alias file"
          end
        else
          raise ArgumentError, "Alias file not found"
        end
      else
        file = File.dirname(__FILE__) + "/../lang/#{options[:language]}.txt"
      end
      @sentiment_values = load_sentiment_file(file)
      unless options[:include_symbols] == false
        # load the symbols file (emoticons and other symbols)
        @sentiment_values.merge!(load_sentiment_file(File.dirname(__FILE__) + "/../lang/symbols.txt"))
      end
    else
      if options[:files].empty?
        raise ArgumentError, "No language or files provided"
      else
        @sentiment_values = {}
        options[:files].each do |file|
          @sentiment_values.merge!(load_sentiment_file(file))
        end
      end
    end

  end

  # analyzes the sentiment of the provided text.
  def analyze(text)
    sentiment_total = 0.0

    scores_added = 0
    (@options[:start_ngram]..@options[:end_ngram]).each do |i|
      ngrams(i, text.to_s).each do |token|
        score = score_token(token)
        unless score.nil?
          sentiment_total += score
          scores_added += 1
        end
      end
    end
    
    if @options[:normalize_score]
      sentiment_total = normalize_score(sentiment_total, scores_added)
    end
    if @options[:ternary_output]
      if sentiment_total > @options[:max_threshold]
        1
      elsif sentiment_total < @options[:min_threshold]
        -1
      else
        0
      end
    else
      sentiment_total
    end
  end

  alias_method :analyse, :analyze

  private

  def score_token(token)
    # try the downcased token verbatim
    used_token = token
    sentiment_value = @sentiment_values[token.downcase]
    unless sentiment_value
      # try the token without symbols
      token_without_symbols = token.gsub(/[^\w\s]+/, "")
      sentiment_value = @sentiment_values[token_without_symbols.downcase]
      if sentiment_value
        used_token = token_without_symbols
      end
    end
    if sentiment_value
      puts "#{used_token}: #{sentiment_value}" if @options[:debug]
      sentiment_value
    else
      puts "#{used_token}: nil" if @options[:debug]
      nil
    end
  end

  def ngrams(n, string)
    string.split.each_cons(n).to_a.collect {|words| words.join(" ")}
  end

  # load the specified sentiment file into a hash
  def load_sentiment_file(path)
    sentiment_values = {}

    sentiment_file = File.new(path, "r:UTF-8")
    while (line = sentiment_file.gets)
      parsed_line = line.chomp.split(/\s*([\d.-]+):\s*([^\s].*)/)
      if parsed_line.size == 3
        score = parsed_line[1]
        text = parsed_line[2]
        if score and text
          sentiment_values[text.downcase] = score.to_f
        end
      end
    end
    sentiment_file.close

    sentiment_values
  end

  # load the specified alias file into a hash
  def load_alias_file(path)
    file = File.open(path, "r:UTF-8") {|f| f.read}
    JSON.parse(file)
  end

  def normalize_score(score, count)
    factor = NORMALIZE_TO.to_f / count.to_f
    (score * factor).round
  end

end