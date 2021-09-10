require 'sqlite3'
db = SQLite3::Database.new('dataset.db')

db.execute <<-SQL
  SELECT COUNT (passed_days)
  FROM posts
SQL

db.execute <<-SQL
  SELECT id, passed_days, (target_score - current_score) AS change 
  FROM posts 
  ORDER BY change DESC LIMIT 100
SQL

db.execute <<-SQL
  SELECT COUNT(*)
  FROM posts
SQL



