# LOG IN AS USER W205
su - w205;


# MAKE FOLDER /data/csvDump
mkdir /data/csvDump;


# USING HIVE, DUMP HIVE TABLE TO TSV/CSV
hive -e "select * from gameday_base_table" > /data/csvDump/temp.csv;


# LOG OUT OF USER W205
exit;
