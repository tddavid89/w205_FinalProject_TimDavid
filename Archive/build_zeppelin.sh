su - w205

exit

cd /data

git clone https://github.com/elbamos/Zeppelin-With-R/tree/rinterpreter incubator-zeppelin-rinterpreter

cd incubator-zeppelin-rinterpreter


wget -O /data/apache-maven-3.3.3-bin.tar.gz http://www.trieuvan.com/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
cd /data/ && sudo -u w205 tar xvzf /data/apache-maven-3.3.3-bin.tar.gz

# SET PATH FOR MAVEN
export M2_HOME=/usr/local/apache-maven-3.3.3
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

# RUN FOLLOWING COMMAND TO REBUILD INTERPRETER ITEMS
mvn clean package -DskipTests
