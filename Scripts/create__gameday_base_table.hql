DROP TABLE IF EXISTS gameday_base_table;

CREATE EXTERNAL TABLE gameday_base_table(
  b String,
  s String,
  o String,
  stand String,
  b_height String,
  p_throws String,
  atbat_des String,
  event_num String,
  event String,
  home_team_runs String,
  away_team_runs String,
  inning_side String,
  inning String,
  batter_name String,
  pitcher_name String,
  date_1 String,
  des String,
  id String,
  type_bsx String,
  x String,
  y String,
  start_speed String,
  end_speed String,
  sz_top String,
  sz_bot String,
  pfx_x String,
  pfx_z String,
  px String,
  pz String,
  x0 String,
  y0 String,
  z0 String,
  vx0 String,
  vy0 String,
  vz0 String,
  ax String,
  ay String,
  az String,
  break_y String,
  break_angle String,
  break_length String,
  pitch_type String,
  type_confidence String,
  zone String,
  nasty String,
  spin_dir String,
  spin_rate String,
  on_2b String,
  on_1b String,
  on_3b String
)
PARTITIONED BY (date String)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar" = '"',
  "escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/w205final'
TBLPROPERTIES('serialization.null.format'='', 'skip.header.line.count'='1');
