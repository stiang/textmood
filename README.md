## TextMood - Simple, powerful sentiment analyzer
TextMood is a simple and powerful sentiment analyzer, provided as a Ruby gem with 
a command-line tool for simple interoperability with other processes. It takes text 
as input and returns a sentiment score.

The sentiment analysis is relatively simple, and works by splitting the text into
tokens and comparing each token to a pre-selected sentiment score for that token.
The combined score for all tokens is then returned.

However, TextMood also supports doing multiple passes over the text, splitting
it into tokens of N words (N-grams) for each pass. By adding multi-word tokens to 
the sentiment file and using this feature, you can achieve much greater accuracy
than with just single-word analysis.

### Summary of features
* Bundles baseline sentiment scores for many languages, making it easy to get started
* CLI tool that makes it extremely simple to get sentiment scores for any text
* Supports multiple passes for any range of N-grams
* Has a flexible API that’s easy to use and understand

### Bundled languages
* English ("en") - decent quality, copied from cmaclell/Basic-Tweet-Sentiment-Analyzer
* Russian ("ru") - low quality, raw Google Translate of the English file
* Spanish ("es") - low quality, raw Google Translate of the English file
* German ("de") - low quality, raw Google Translate of the English file
* French ("fr") - low quality, raw Google Translate of the English file
* Norwegian Bokmål ("no_NB") - low quality, slightly improved Google Translate of the English file
* Swedish ("se") - low quality, raw Google Translate of the English file
* Danish ("da") - low quality, raw Google Translate of the English file

Please see the Contribute section for more info on how to improve the quality of these
files, or adding new ones.

### Installation
The easiest way to get the latest stable version is to install the gem:

    gem install textmood

If you’d like to get the bleeding-edge version:

    git clone https://github.com/stiang/textmood

The *master* branch will normally be in sync with the gem, but there may be
newer code in branches.

### Usage
TextMood can be used as a Ruby library or as a standalone CLI tool.

#### Ruby library
You can use it in a Ruby program like this:
```ruby
require "textmood"

# The :language parameter makes TextMood use one of the bundled language sentiment files
tm = TextMood.new(language: "en")
score = tm.analyze("some text")
#=> '1.121'

# The :files parameter makes TextMood ignore the bundled sentiment files and use the
# specified files instead. You can specify as many files as you want.
tm = TextMood.new(files: ["en_US-mod1.txt", "emoticons.txt"])

# Use :alias_file to make TextMood look up the file to use for the given language tag
# in a JSON file containing a hash with {"language_tag": "path_to_file"} mappings
tm = TextMood.new(language: "zw", alias_file: "my-custom-languages.json")

# :normalize_score will try to normalize the score to an integer between +/- 100,
# based on how many tokens were scored, which can be useful when trying to compare
# scores for texts of different length
tm = TextMood.new(language: "en", normalize_score: true)
score = tm.analyze("some text")
#=> '14'

# :ternary_output will make TextMood return one of three fixed values:
# 1 for positive, 0 for neutral and -1 for negative
tm = TextMood.new(language: "en", ternary_output: true)
score = tm.analyze("some text")
#=> '1'

# :min_threshold and :max_threshold lets you customize the way :ternary_output 
# treats different values. The options below will make all scores below 10 negative, 
# 10-20 will be neutral, and above 20 will be positive. Note that these thresholds
# are compared to the normalized score, if applicable.
tm = TextMood.new(language: "en", 
                  ternary_output: true, 
                  normalize_score: true, 
                  min_threshold: 10, 
                  max_threshold: 20)
score = tm.analyze("some text")
#=> '0'

# TextMood will by default make one pass over the text, checking every word, but it
# supports doing several passes for any range of word N-grams. Both the start and end 
# N-gram can be specified using the :start_ngram and :end_ngram options
tm = TextMood.new(language: "en", debug: true, start_ngram: 2, end_ngram: 3)
score = tm.analyze("some long text with many words")
#(stdout): some long: 0.1
#(stdout): long text: 0.1
#(stdout): text with: -0.1
#(stdout): with many: -0.1
#(stdout): many words: -0.1
#(stdout): some long text: -0.1
#(stdout): long text with: 0.1
#(stdout): text with many: 0.1
#(stdout): with many words: 0.1
#=> '0.1'

# :debug prints out all tokens to stdout, alongs with their values (or 'nil' when the
# token was not found)
tm = TextMood.new(language: "en", debug: true)
score = tm.analyze("some text")
#(stdout): some: 0.1
#(stdout): text: 0.1
#(stdout): some text: -0.1
#=> '0.1'
```

#### CLI tool
You can also pass some UTF-8-encoded text to the CLI tool and get a score back, like so 
```bash
textmood -l en "<some text>"
-0.4375
```

Alternatively, you can pipe some text to textmood on stdin:
```bash
echo "<some text>" | textmood -l en
-0.4375
```

The cli tool has many useful options, mostly mirroring those of the library. Here’s the
output from `textmood -h`:
```
Usage: textmood [options] "<text>"
            OR
       echo "<text>" | textmood [options]"

Returns a sentiment score of the provided text. Above 0 is usually
considered positive, below is considered negative.

MANDATORY options:
    -l, --language LANGUAGE          The IETF language tag for the provided text.
                                     Examples: en_US, no_NB

              OR

    -f, --file PATH TO FILE          Use the specified sentiment file. May be used
                                     multiple times to load several files. No other
                                     files will be loaded if this option is used.

OPTIONAL options:
    -a, --alias-file PATH TO FILE    JSON file containing a hash that maps language codes to
                                     sentiment score files. This lets you use the convenience of
                                     language codes with custom sentiment score files.

    -n, --normalize-score            Tries to normalize the score to an integer between +/- 100
                                     according to the number of tokens that were scored, making
                                     it more feasible to compare scores for texts of different
                                     length

    -t, --ternary-output             Return 1 (positive), -1 (negative) or 0 (neutral)
                                     instead of the actual score. See also --min-threshold
                                     and --max-threshold.

    -i, --min-threshold FLOAT        Scores lower than this are considered negative when
                                     using --ternary-output (default 0.5). Note that the
                                     threshold is compared to the normalized score, if applicable

    -x, --max-threshold FLOAT        Scores higher than this are considered positive when
                                     using --ternary-output (default 0.5). Note that the
                                     threshold is compared to the normalized score, if applicable

    -s, --start-ngram INTEGER        The lowest word N-gram number to split the text into
                                     (default 1). Note that this only makes sense if the
                                     sentiment file has tokens of similar N-gram length

    -e, --end-ngram INTEGER          The highest word N-gram number to to split the text into
                                     (default 1). Note that this only makes sense if the
                                     sentiment file has tokens of similar N-gram length

    -k, --skip-symbols               Do not include symbols file (emoticons etc.). Only applies
                                     when using -l/--language.

    -c, --config PATH TO FILE        Use the specified config file. If not specified, textmood will look
                                     for /etc/textmood.cfg and ~/.textmood. Settings in the user config
                                     will override settings from the global file.

    -d, --debug                      Prints out the score for each token in the provided text
                                     or 'nil' if the token was not found in the sentiment file

    -h, --help                       Show this message
```

### Configuration files for the CLI tool
The CLI tool will look for /etc/textmood and ~/.textmood unless the -c/--config option
is used, in which case only that file is used. The configuration files are basic, flat
YAML files that use the same keys as the library understands:
```yaml
# Assume that text is in this language, unless overridden on the command line.
# Do not use this in conjunction with the files setting.
language: en

# Load these sentiment score files instead of using any of the bundled ones
# Do not use this in conjunction with the language setting
files: [/path/to/file1, /path/to/file2]

# Use a global alias file to resolve language codes
alias_file: /home/john/textmood/aliases.json

# Always normalize the score
normalize_score: true

# Use ternary output
ternary_output: true

# Use these thresholds when using ternary output
max_threshold: 10
min_threshold: 5

# Do three passes, scoring unigrams, bigrams and trigrams
start_ngram: 1
end_ngram: 3

# Do not load the symbols file when using a bundled language
skip_symbols: true

# Always print debug info
debug: true
```

## Sentiment files
The included sentiment files reside in the *lang* directory. I hope to add many
more baseline sentiment files in the future.

Sentiment files should be named according to the IETF language tag, like *en* or
*no_NB*, and contain one colon-separated line per token, like so:
```
1.0: epic
1.0: good
1.0: upright
0.958: fortunate
0.875: wonderfulness
0.875: wonderful
0.875: wide-eyed
0.875: wholesomeness
0.875: well-to-do
0.875: well-situated
0.6: well suited
-0.3: dishonest
-0.5: tragedy
```
The score, which must be between -1.0 and 1.0, is to the left of the first ':', 
and everything to the right is the (potentially multi-word) token.

# TODO
* Add more sentiment language files
* Improve sentiment files, adding bigrams and trigrams
* Improve test coverage

## Contribute
Including baseline word/N-gram scores for many different languages is one 
of the expressed goals of this project. If you are able to contribute scores 
for a missing language or improve an existing one, it would be much appreciated!

The process is the usual:
* Fork
* Add/improve
* Pull request

## Credits
Loosely based on https://github.com/cmaclell/Basic-Tweet-Sentiment-Analyzer

## Author
Stian Grytøyr
