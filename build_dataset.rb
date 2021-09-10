require 'pry'
require 'scylla' # https://github.com/hashwin/scylla
require 'nlp_pure/segmenting/default_word'  # https://github.com/parhamr/nlp-pure
require 'nlp_pure/segmenting/default_sentence'
require 'sqlite3' # https://github.com/sparklemotion/sqlite3-ruby
require 'http'

db = SQLite3::Database.new('dataset.db')
http = HTTP.accept(:json)
file = File.open('raw/2021-03.txt', 'r')

counter = 0
fails = 0

until file.eof?
  begin
    #puts "Reached: #{counter}" if counter % 1000 == 0

    if counter < 19296001 || counter % 400 != 0
      counter += 1
      file.readline
      next
    end

  post = JSON.parse(file.readline)
  passed_days = (post["retrieved_utc"] - post["created_utc"]) / (60*60*24)
  next if post['archived'] || passed_days > 180
  response = http.get("https://www.reddit.com#{post['permalink']}.json").parse
  next unless response.is_a?(Array)

  new_post = response.first['data']["children"].first['data']
  target_days = if new_post['archived']
                  180
                else
                  real_interval = (Time.now.to_i - post["created_utc"]) / (60*60*24)
                  real_interval > 180 ? 180 : real_interval
                end

  #subreddit = http.get("https://www.reddit.com/r/#{new_post['subreddit']}/about.json").parse['data']

  dataset_row = {
    target_score: new_post['score'],
    target_days: target_days,
    passed_days: passed_days,
    current_score: post['score'],
    upvote_ratio: post['upvote_ratio'],
    nsfw: post['thumbnail'] == 'nsfw',
    spoiler: post['spoiler'],
    over_18: post['over_18'],
    distinguished: !!post['distinguished'],
    gilded: post['gilded'],
    num_comments: post['num_comments'],
    media_only: post['media_only'],
    any_media: !!post['media'] || !!post['media_embed'].any? || !!post['secure_media'] || !!post['secure_media_embed'].any?,
    locked: post['locked'],
    hide_score: post['hide_score'],
    stickied: post['stickied'],
    contest_mode: post['contest_mode'],
    subscribers: post['subreddit_subscribers'],
    is_english: (post['title'] + ' ' + post['selftext']).language == 'english',
    title_symbols: post['title'].gsub(/\s+/, "").size,
    title_words: NlpPure::Segmenting::DefaultWord.parse(post['title']).size,
    body_symbols: post['selftext'].gsub(/\s+/, "").size,
    body_words: NlpPure::Segmenting::DefaultWord.parse(post['selftext']).size,
    body_sentences: NlpPure::Segmenting::DefaultSentence.parse(post['selftext']).reject { |c| c.empty? }.size,
  }

  db_row_data = dataset_row.transform_values do |v|
    if !!v == v
      v ? 1 : 0
    else
      v
    end
  end
  db.execute(<<-SQL, [post['id']] + db_row_data.values)
    INSERT OR IGNORE INTO posts (
      id,
      target_score,
      target_days,
      passed_days,
      current_score,
      upvote_ratio,
      nsfw,
      spoiler,
      over_18,
      distinguished,
      gilded,
      num_comments,
      media_only,
      any_media,
      locked,
      hide_score,
      stickied,
      contest_mode,
      subscribers,
      is_english,
      title_symbols,
      title_words,
      body_symbols,
      body_words,
      body_sentences) 
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);
  SQL
  counter += 1
  puts "Done: #{counter}"


  rescue => e

    fails += 1
    if fails % 5 == 0
      #binding.pry
      puts "Failed: #{fails}"
    end
  end
end


