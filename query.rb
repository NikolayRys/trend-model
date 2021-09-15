#!/usr/bin/env ruby

require 'pry'
require 'scylla' # https://github.com/hashwin/scylla
require 'nlp_pure/segmenting/default_word'  # https://github.com/parhamr/nlp-pure
require 'nlp_pure/segmenting/default_sentence'
require 'http'

target_days = 30
url = 'https://www.reddit.com/r/personalfinance/comments/owhy0r/leverage_through_leaps_for_the_diy_investor/'


http = HTTP.accept(:json)
post = http.get("#{url}.json").parse.first['data']["children"].first['data']

passed_days = (Time.now.to_i - post["created_utc"]) / (60*60*24)

if post['archived'] || passed_days > 180
  post['score']
else
  puts({
    'instances' => [
      {
      'target_days' => target_days,
      'passed_days' => passed_days,
      'current_score' => post['score'],
      'upvote_ratio' => post['upvote_ratio'],
      'nsfw' => post['thumbnail'] == 'nsfw',
      'spoiler' => post['spoiler'],
      'over_18' => post['over_18'],
      'distinguished' => !!post['distinguished'],
      'gilded' => post['gilded'],
      'num_comments' => post['num_comments'],
      'media_only' => post['media_only'],
      'any_media' => !!post['media'] || !!post['media_embed'].any? || !!post['secure_media'] || !!post['secure_media_embed'].any?,
      'locked' => post['locked'],
      'hide_score' => post['hide_score'],
      'stickied' => post['stickied'],
      'contest_mode' => post['contest_mode'],
      'subscribers' => post['subreddit_subscribers'],
      'is_english' => (post['title'] + ' ' + post['selftext']).language == 'english',
      'title_symbols' => post['title'].gsub(/\s+/, "").size,
      'title_words' => NlpPure::Segmenting::DefaultWord.parse(post['title']).size,
      'body_symbols' => post['selftext'].gsub(/\s+/, "").size,
      'body_words' => NlpPure::Segmenting::DefaultWord.parse(post['selftext']).size,
      'body_sentences' => NlpPure::Segmenting::DefaultSentence.parse(post['selftext']).reject { |c| c.empty? }.size,
      }
    ] }.to_json)
end
