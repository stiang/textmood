## TextMood - Simple sentiment analyzer
*TextMood* is a simple sentiment analyzer, provided as a Ruby gem with a command-line
tool for simple interoperability with other processes. It takes text as input and 
returns a sentiment score. Above 0 is typically considered positive, below is 
considered negative.

The goal is to have a robust and simple tool that comes with baseline sentiment files
for many languages.

### Installation
The easiest way to get the latest stable version is to use gem:

    gem install textmood

If you’d like to get the bleeding-edge version:

    git clone https://github.com/stiang/textmood

### Usage
TextMood can be used as a ruby library or as a standalone CLI tool.

#### Ruby library
You can use textmood in a ruby program like this:
```ruby
require "textmood"

# The :lang parameter makes TextMood use one of the bundled language sentiment files
scorer = TextMood.new(lang: "en_US")
score = scorer.score_text("some text")
#=> '1.121'

# The :files parameter makes TextMood ignore the bundled sentiment files and use the
# specified files instead. You can specify as many files as you want.
scorer = TextMood.new(files: ["en_US-mod1.txt", "emoticons.txt"])

# TextMood will by default make one pass over the text, checking every word, but it
# supports doing several passes for any range of word N-grams. Both the start and end 
# N-gram can be specified using the :start_ngram and :end_ngram options
scorer = TextMood.new(lang: "en_US", debug: true, start_ngram: 2, end_ngram: 3)
score = scorer.score_text("some long text with many words")
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

# Using :normalize, you can make TextMood return a normalized value: 1 for positive, 
# 0 for neutral and -1 for negative
scorer = TextMood.new(lang: "en_US", normalize: true)
score = scorer.score_text("some text")
#=> '1'

# :min_threshold and :max_threshold lets you customize the way :normalize treats
# different values. The options below will make all scores below 1 negative, 
# 1-2 will be neutral, and above 2 will be positive.
scorer = TextMood.new(lang: "en_US", normalize: true, min_threshold: 1, max_threshold: 2)
score = scorer.score_text("some text")
#=> '0'

# :debug prints out all tokens to stdout, alongs with their values (or 'nil' when the
# token was not found)
scorer = TextMood.new(lang: "en_US", debug: true)
score = scorer.score_text("some text")
#(stdout): some: 0.1
#(stdout): text: 0.1
#(stdout): some text: -0.1
#=> '0.1'
```

#### CLI tool
You can also pass some UTF-8-encoded text to the CLI tool and get a score back, like so 
```bash
textmood -l en_US "<some text>"
-0.4375
```

The cli tool has many useful options, mostly mirroring those of the library. Here’s the
output from `textmood -h`:
```
Usage: textmood [options] "<text>"

Returns a floating-point sentiment score of the provided text.
Above 0 is considered positive, below is considered negative.

MANDATORY options:
    -l, --language LANGUAGE          The IETF language tag for the provided text.
                                     Examples: en_US, no_NB

              OR

    -f, --file PATH TO FILE          Use the specified sentiment file. May be used
                                     multiple times to load several files. No other
                                     files will be loaded if this option is used.

OPTIONAL options:
        --start-ngram INTEGER        The lowest word N-gram number to split the text into
                                     (default 1). Note that this only makes sense if the
                                     sentiment file has tokens of similar N-gram length

        --end-ngram INTEGER          The highest word N-gram number to to split the text into
                                     (default 1). Note that this only makes sense if the
                                     sentiment file has tokens of similar N-gram length

    -n, --normalize                  Return 1 (positive), -1 (negative) or 0 (neutral)
                                     instead of the actual score. See also --min and --max.

        --min-threshold FLOAT        Scores lower than this are considered negative when
                                     using --normalize (default -0.5)

        --max-threshold FLOAT        Scores higher than this are considered positive when
                                     using --normalize (default 0.5)

    -s, --skip-symbols               Do not include symbols file (emoticons etc.).
                                     Only applies when using -l/--language.

    -d, --debug                      Prints out the score for each token in the provided text
                                     or 'nil' if the token was not found in the sentiment file

    -h, --help                       Show this message
```

## Sentiment files
The included sentiment files reside in the *lang* directory. I hope to add many
more baseline sentiment files in the future.

Sentiment files should be named according to the IETF language tag, like *en_US*,
and contain one colon-separated line per token, like so:
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
```
The score is to the left of the first ':', and everything to the right is the
(potentially multi-word) token.

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
