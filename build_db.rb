require 'sqlite3'

db = SQLite3::Database.new('dataset.db')

db.execute <<-SQL
  create table if not exists posts(
    id varchar(30),
    target_score INT,
    target_days INT,
    passed_days INT,
    current_score INT,
    upvote_ratio REAL,
    nsfw BOOL,
    spoiler BOOL,
    over_18 BOOL,
    distinguished BOOL,
    external_content BOOL,
    gilded BOOL,
    num_comments INT,
    media_only BOOL,
    any_media BOOL,
    locked BOOL,
    hide_score BOOL,
    stickied BOOL,
    contest_mode BOOL,
    subscribers INT,
    is_english BOOL,
    title_symbols INT,
    title_words INT,
    body_symbols INT,
    body_words INT,
    body_sentences INT,
    quarantine BOOL
  );

  CREATE UNIQUE INDEX idx_posts_id ON posts (id);
SQL

db.execute <<-SQL
  create table if not exists subreddits (
    name varchar(30),
    quarantine INT,
    subscribers INT,
    restrict_posting INT
  );

  CREATE UNIQUE INDEX idx_subreddits_name ON subreddits (name);
SQL
