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
    negative_total  = 0.0
    positive_total  = 0.0
    neutral_total   = 0.0

    scores_added   = 0
    negative_added = 0
    positive_added = 0
    neutral_added  = 0
    not_found      = 0

    (@options[:start_ngram]..@options[:end_ngram]).each do |i|
      ngrams(i, text.to_s).each do |token|
        score = score_token(token)
        if score.nil?
          not_found += 1
        else
          sentiment_total += score
          if score > 0
            positive_total += score
            positive_added += 1
          elsif score < 0
            negative_total += score
            negative_added += 1
          else
            neutral_total += score
            neutral_added += 1
          end
          scores_added += 1
        end
      end
    end
    
    if @options[:normalize_score]
      actual_score = normalize_score(sentiment_total, scores_added)
    else
      actual_score = sentiment_total
    end

    if @options[:verbose]
      puts "" if @options[:debug]
      combined_avg  = (scores_added > 0) ? ", #{(sentiment_total.to_f / scores_added.to_f)} avg." : ""
      combined_text = "Combined score: #{sentiment_total} (#{scores_added} tokens#{combined_avg})"
      puts combined_text
      negative_avg  = (negative_added > 0) ? ", #{(negative_total.to_f / negative_added.to_f)} avg." : ""
      negative_text = "Negative score: #{negative_total} (#{negative_added} tokens#{negative_avg})"
      puts negative_text
      positive_avg  = (positive_added > 0) ? ", #{(positive_total.to_f / positive_added.to_f)} avg." : ""
      positive_text = "Positive score: #{positive_total} (#{positive_added} tokens#{positive_avg})"
      puts positive_text
      neutral_avg  = (neutral_added > 0) ? ", #{(neutral_total.to_f / neutral_added.to_f)} avg." : ""
      neutral_text = "Neutral score: #{neutral_total} (#{neutral_added} tokens#{neutral_avg})"
      puts neutral_text
      puts "Not found: #{not_found} tokens"
    end

    if @options[:ternary_output]
      if actual_score > @options[:max_threshold]
        1
      elsif actual_score < @options[:min_threshold]
        -1
      else
        0
      end
    else
      actual_score
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
      puts "#{used_token}: #{sentiment_value}" if @options[:debug] and not @options[:skip_found_debug]
      sentiment_value
    else
      puts "#{used_token}: nil" if @options[:debug] and not @options[:skip_not_found_debug]
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
      unless (line.match(/^\s*#/))
        parsed_line = line.chomp.split(/\s*([\d.-]+):\s*([^\s].*)/)
        if parsed_line.size == 3
          score = parsed_line[1]
          text = parsed_line[2]
          if score and text
            sentiment_values[text.downcase] = score.to_f
          end
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
    if score != 0
      factor = NORMALIZE_TO.to_f / count.to_f
      (score * factor).round
    else
      score
    end
  end

end
