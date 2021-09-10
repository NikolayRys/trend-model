require 'sqlite3'
require 'csv'
names = %w[dataset_03.db dataset_04.db dataset_05.db dataset_06.db]

def access_db(name)
  db = SQLite3::Database.new(name)
  db.results_as_hash = true
  db.type_translation = true
  db.translator.add_translator( 'BOOL' ) { |_, value| !!(value == 1) }
  db
end

CSV.open('dataset.csv', 'w') do |csv|
  csv << %w[target_score target_days passed_days current_score upvote_ratio nsfw spoiler over_18
    distinguished gilded num_comments media_only any_media locked hide_score stickied contest_mode
    subscribers is_english title_symbols title_words body_symbols body_words body_sentences]
  names.each do |name|
    puts('Starting: ' + name)
    db = access_db(name)
    db.execute( "select * from posts" ) do |row|
      csv << row.values[1..-1]
    end
  end
end
