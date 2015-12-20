# exit w205 and move to root
#exit

#cd to /data folder
#cd /data

# run R script
#Rscript pitchRx_main.R "2015-04-05"

# log back on to w205
#su - w205

# make directory in hdfs for partition
hdfs dfs -mkdir /user/w205/w205final/date=2015_04_05

# put csv file into hdfs directory
hdfs dfs -put /data/w205_test.csv /user/w205/w205final/date=2015_04_05

# add partition to hive table
hive -e "ALTER TABLE gameday_base_table ADD PARTITION(date='2015_04_05');"

# make directory to dump csv file
mkdir /data/csvDump

# move files from hive to csv
hive -e "SELECT * FROM gameday_base_table" > /data/csvDump/temp.csv

# Clone GitHub that contains R interpreter
git clone https://github.com/elbamos/Zeppelin-With-R.git incubator-zeppelin-rinterpreter

# cd into repository you just cloned
cd incubator-zeppelin-rinterpreter

# Install Apache Maven 3.3.3
wget -O /data/apache-maven-3.3.3-bin.tar.gz http://www.trieuvan.com/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
cd /data/ && sudo -u w205 tar xvzf /data/apache-maven-3.3.3-bin.tar.gz

# SET PATH FOR MAVEN
export M2_HOME=/usr/local/apache-maven-3.3.3
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

# RUN FOLLOWING COMMAND TO (RE)BUILD INTERPRETER ITEMS
mvn clean package -DskipTests

# START ZEPPELIN
/data/incubator-zeppelin-rinterpreter/bin/zeppelin-daemon.sh start

# START HIVE SERVER
hive --service hiveserver2