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
    nsfw INT,
    spoiler INT,
    over_18 INT,
    distinguished INT,
    external_content INT,
    gilded INT,
    num_comments INT,
    media_only INT,
    any_media INT,
    locked INT,
    hide_score INT,
    stickied INT,
    contest_mode INT,
    subscribers INT,
    is_english INT,
    title_symbols INT,
    title_words INT,
    body_symbols INT,
    body_words INT,
    body_sentences INT,
    quarantine INT
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
