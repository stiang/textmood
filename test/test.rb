#!/usr/bin/env ruby
#encoding: utf-8

if RUBY_VERSION < '1.9'
  $KCODE='u'
else
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

require "test/unit"
# require "./#{File.dirname(__FILE__)}/../lib/textmood"
require "textmood"

include Test::Unit::Assertions

class TestScorer < Test::Unit::TestCase

  def setup
    @tm = TextMood.new({:language => "en"})
  end

  def test_negative
    max = -0.01
    texts = ["This is just terrible"]
    texts.each do |text|
      actual_score = @tm.analyze(text)
      assert((actual_score < max), "actual: #{actual_score} >= max: #{max} for '#{text}'")
    end
  end

  def test_neutral
    min = -0.5
    max =  0.5
    texts = ["This is neutral"]
    texts.each do |text, test_score|
      actual_score = @tm.analyze(text)
      assert((actual_score < max and actual_score > min), "min: #{min} <= actual: #{actual_score} >= max: #{max} for '#{text}'")
    end
  end

  def test_positive
    min = 0.01
    texts = ["This is amazing!"]
    texts.each do |text, test_score|
      actual_score = @tm.analyze(text)
      assert((actual_score >= min), "actual: #{actual_score} <= max: #{min} for '#{text}'")
    end
  end

end