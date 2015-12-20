# log on to w205
#su - w205

# make hdfs directory
sudo -u w205 hdfs dfs -mkdir /user/w205/w205final

# get hql file from github
wget https://raw.githubusercontent.com/tddavid89/w205_FinalProject_TimDavid/master/Scripts/create__gameday_base_table.hql

# Run hql file in order to create gameday_base_table
hive -f ./create__gameday_base_table.hql

# cd to /data folder
cd /data

# extract pitchRx_main.R script
wget https://raw.githubusercontent.com/tddavid89/w205_FinalProject_TimDavid/master/Scripts/pitchRx_main.R

# run R script
Rscript pitchRx_main.R "2015-04-05"

# make directory in hdfs for partition
sudo -u w205 hdfs dfs -mkdir /user/w205/w205final/date=2015_04_05

# put csv file into hdfs directory
sudo -u w205 hdfs dfs -put /data/w205_test.csv /user/w205/w205final/date=2015_04_05

# add partition to hive table
hive -e "ALTER TABLE gameday_base_table ADD PARTITION(date='2015_04_05');"

# Pull postgres sql script off of github
wget https://raw.githubusercontent.com/tddavid89/w205_FinalProject_TimDavid/master/Scripts/create__gameday_base_table.sql

# create postgres database 'gameday'
createdb -U postgres gameday

# create postgres table 'gameday_base_table'
psql -U postgres \gameday -f create__postgres_gameday_table.sql

# use sqoop to transfer hive table to postgres
sqoop export --connect jdbc:postgresql://localhost:5432/gameday --username postgres --table gameday_base_table --export-dir /user/w205/w205final/* ;

# make directory to dump csv file
mkdir /data/csvDump

# move files from hive to csv
hive -e "SELECT * FROM gameday_base_table" > /data/csvDump/temp.csv

#cd /data
cd /data

# Clone GitHub that contains R interpreter
git clone https://github.com/elbamos/Zeppelin-With-R.git incubator-zeppelin-rinterpreter

# cd into repository you just cloned
cd /data/incubator-zeppelin-rinterpreter

# Install Apache Maven 3.3.3
wget -O /data/apache-maven-3.3.3-bin.tar.gz http://www.trieuvan.com/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
cd /data/ && sudo -u w205 tar xvzf /data/apache-maven-3.3.3-bin.tar.gz

# SET PATH FOR MAVEN
export M2_HOME=/usr/local/apache-maven-3.3.3
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

# cd into zeppelin repository you just cloned
cd /data/incubator-zeppelin-rinterpreter

# RUN FOLLOWING COMMAND TO (RE)BUILD INTERPRETER ITEMS
mvn clean package -DskipTests

# START ZEPPELIN
/data/incubator-zeppelin-rinterpreter/bin/zeppelin-daemon.sh start

# START HIVE SERVER
hive --service hiveserver2