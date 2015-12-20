# w205 Final Project
##### Tim David

--------------------------------------------------------------------------------

The following are instructions for running the code necessary for my final project.

If you would like to see all of the code executed as a video, please click the link to the video walkthrough below, otherwise, please continue to the "**_Log On Information_**" portion of this readme file.

---
### **Video Code Walkthrough**:

[![Video Code Walkthrough](http://img.youtube.com/vi/Kv5mWxu1fTo/0.jpg)](https://www.youtube.com/watch?v=Kv5mWxu1fTo "Everything Is AWESOME")

---

### **Log On Information**:

**AMI**:  w205_finalproject_TimDavid_1.0


|      PORT     | DESCRIPTION                                                                                                                       |
|:---------------:|------------|
| 4040 | Spark |
| 50070 | Hadoop |
| 8080 | Webserver |
| 5432 | Postgres|
| 22 | SSH |
| 8787 | RStudio |
| 3838 | Shiny |
| 8088 | Zeppelin |
| 10000 |   |


### **Step 1: Create Essential Files and Folders**
#### _Log in as user_ **_w205_**:

```
su - w205
```

#### _HDFS folder_:

```
hdfs dfs -mkdir /user/w205/w205final
```

#### _Hive Table_:


*Start Hive*:

```
hive
```

_Create_ "**_gameday_base_table_**" , _partitioned by date (day)_:

```
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
  on_3b String,
  count String
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
```

*Quit Hive*:

```
quit;
```

#### _R Script_:

_Navigate to_ **/data** and create/edit **pitchRx_main.R**

```
cd /data

emacs pitchRx_main.R
```

_Copy and paste the following code as input_: 

```
##########################
#SETUP + DATA COLLECTION
##########################

args <- commandArgs(TRUE)

#LOAD REQUIRED PACKAGES
library(ggplot2)
library(pitchRx)
library(dplyr)
library(plyr)
library(Hmisc)
library(lattice)

#DETERMINE WHICH XML ITEMS WE NEED + SCRAPE DATA FOR TIME FRAME
files <- c("inning/inning_all.xml", "players.xml", "inning/inning_hit.xml")
#dat <- scrape(start = "2015-09-29", end = "2015-09-29", suffix = files)
#dat <- scrape(start = Sys.Date(), end = Sys.Date() - 1, suffix = files)
dat <- scrape(start = args[1], end = args[1], suffix = files)

##########################
#DATA MANIPULATION
##########################

#ASSIGN VARIABLES TO DATAFRAMES
dat.atbat <- dat$atbat
dat.coach <- dat$coach
dat.player <- dat$player
dat.umpire <- dat$umpire
dat.hip <- dat$hip
dat.action <- dat$action
dat.pitch <- dat$pitch
dat.po <- dat$po
dat.runner <- dat$runner
pitcher_atbats <- dat.atbat

#RENAME TYPE TO TYPE_BSX
names(dat.pitch)[names(dat.pitch) == "type"] <- "type_bsx"

#JOIN DATAFRAMES PITCHER_ATBATS + PITCH
pitcher <- join(pitcher_atbats, dat.pitch, by = c("num", "url"), type="inner")

#DROP IRRELEVANT COLUMNS
keeps <- c('b','s','o','stand','b_height','p_throws','atbat_des','event_num','event','home_team_runs','away_team_runs','inning_side','inning','batter_name','pitcher_name','date','des','id','type_bsx','x','y','start_speed','end_speed','sz_top','sz_bot','pfx_x','pfx_z','px','pz','x0','y0','z0','vx0','vy0','vz0','ax','ay','az','break_y','break_angle','break_length','pitch_type','type_confidence','zone','nasty','spin_dir','spin_rate','on_1b','on_2b','on_3b','count')

pitcher <- pitcher[,(names(pitcher) %in% keeps)]

pitcher$inning_side.1 <- NULL
pitcher$inning.1 <- NULL
pitcher$event_num.1 <- NULL


#SAVE FILE TO LOCAL DIR
write.csv(pitcher,file="/data/w205_test.csv",row.names=FALSE)
```

--------------------------------------------------------------------------------

### Step 2: Generate Data (Run Scripts)
_First, make sure that both accounts are in location:_ ***/data***

```
cd /data

su - w205

cd /data

exit
```

*Next, run the R Script. The script is designed so that you can enter the specific day that you would like to load, i.e.*:

```
Rscript pitchRx_main.R "2015-04-05"
```

Once the script finishes running, it should generate a file named ***w205_test.csv*** in the **_/data_** folder. In order to load this file into the partition corresponding with the day that it was run, we need to run the following commands:

```
# Switch to user w205:
su - w205

# Make partition folder in hdfs for given day:
hdfs dfs -mkdir /user/w205/w205final/date=2015_04_05

# Move w205_test.csv to partition folder in hdfs:
hdfs dfs -put /data/w205_test.csv /user/w205/w205final/date=2015_04_05
```

Finally, we need to add this new partition to Hive:

```
hive -e "ALTER TABLE gameday_base_table ADD PARTITION(date='2015_04_05');"
```

When we have run all of these scripts, navigate back to the **_root_** user:

```
# Log off user w205:
exit
```

--------------------------------------------------------------------------------

## Step 3: Extract CSV Data For Visualization

```
# LOG IN AS USER W205
su - w205


# MAKE FOLDER /data/csvDump
mkdir /data/csvDump


# USING HIVE, DUMP HIVE TABLE TO TSV/CSV
hive -e "select * from gameday_base_table" > /data/csvDump/temp.csv


# LOG OUT OF USER W205
exit
```

---

### Step 4a: Build Zeppelin Interpreter

```
# Navigate to 'data' folder
cd /data

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
```

---

## Step 4b: Start Zeppelin Instance(s) and Hive Server

```
# START ZEPPELIN
/data/incubator-zeppelin-rinterpreter/bin/zeppelin-daemon.sh start

# START HIVE SERVER
hive --service hiveserver2
```

```
# NAVIGATE TO URL/ZEPPELIN PORT
http://<localhost>:8080/
```

---

## Zeppelin Code

##### **_Check connection to %hive, %spark.r, %pyspark_**:

```
%spark.r
2+2
```

```
%hive
select * from gameday_base_table
```

```
%pyspark
print "hello world!"
```

---
##### **Sample Queries**:

**_Initialize R_**:

load data and set up column headers:

```
%spark.r

dt <- read.csv('//data/csvDump/temp.csv',header=FALSE,sep='\t')


names(dt) <- c("b","s","o","stand","b_height","p_throws","atbat_des","event_num","event","home_team_runs","away_team_runs","inning_side","inning","batter_name","pitcher_name","date","des","id","type_bsx","x","y","start_speed","end_speed","sz_top","sz_bot","pfx_x","pfx_z","px","pz","x0","y0","z0","vx0","vy0","vz0","ax","ay","az","break_y","break_angle","break_length","pitch_type","type_confidence","zone","nasty","spin_dir","spin_rate","on_1b","on_2b","on_3b","count")


#LOAD REQUIRED PACKAGES
library(ggplot2)
library(pitchRx)
library(dplyr)
library(plyr)
library(Hmisc)
library(lattice)

#DEFINE STRIKE ZONE
topKzone <- 3.5
botKzone <- 1.6
inKzone <- -0.95
outKzone <- 0.95
kZone <- data.frame(
  x=c(inKzone, inKzone, outKzone, outKzone, inKzone),
  y=c(botKzone, topKzone, topKzone, botKzone, botKzone)
)
```

**_R Plot_**:

First sample R plot, shows location of all pitches thrown in the given time frame. The color is split by the result of the pitch (Ball (B), Strike (S), Batted Ball (X)), and the shapes are split by pitch type:

```
%spark.r

ggplot(subset(dt,batter_name == "Robinson Cano"),aes(px,pz,color=type_bsx)) + 
    geom_point(aes(shape=pitch_type)) + 
    coord_equal() + 
    geom_path(aes(x,y), data = kZone, lwd = 1, col = "black", alpha = 0.75) + 
    xlab("Horizontal Pitch Location") + ylab("Height From Ground")
```

The second sample plot shows the same as the first, except this time, there is an individual plot for each pitch type (i.e. CH, CU, FC, FF, FT, IN, SI, SL, etc.):

```
%spark.r

# PITCH LOCATION OF ALL PITCHES THROWN
# PLOTS SPLIT BY:
#   PITCH TYPE
# COLOR SPLIT BY:
#   RESULT OF PITCH (BALL(B), STRIKE(S), BATTED BALL(X))
# SHAPES SPLIT BY:
#   PITCH_TYPE

ggplot(dt,aes(px,pz,color=type_bsx)) + 
    geom_point(aes(shape=pitch_type)) + 
    facet_wrap(~ pitch_type) + 
    coord_equal() + 
    geom_path(aes(x,y), data = kZone, lwd = 1, col = "black", alpha = 0.75) +
    xlab("Horizontal Pitch Location") + ylab("Height From Ground")
```

The third sample plot is a contour map of all of the pitches thrown to a particular batter. The graph is split by which hand the pitcher throws with ( L or R ):

```
%spark.r

rCano <- subset(dt, pitch_type %in% c("FF","FC","FS","FT","CH","CU","KN","SI","SL"))

strikeFX(rCano, color = "pitch_type", point.alpha = 0.2,
         adjust = TRUE, contour = TRUE) + facet_grid(. ~ p_throws) + 
  theme(legend.position = "right", legend.direction = "vertical") +
  coord_equal() + theme_bw()
```

The final R sample plot shows box and whisker plots of the velocity of each pitch grouped by each inning of the game:

```
%spark.r

fHernandez <- dt

ggplot(data=fHernandez, aes(factor(inning), end_speed)) + geom_boxplot(outlier.size = 0) + geom_jitter(color='blue',size=0.05) + xlim("1","2","3","4","5","6","7","8","9") + xlab("Inning") + ylab("Pitch Speed (MPH)")
```

---

### **_For Reference When Creating Your Own Plots_**:


_Here are the definitions of each column header, and a short description_:


|      COLUMN     | DESCRIPTION                                                                                                                       |
|:---------------:|-----------------------------------------------------------------------------------------------------------------------------------|
|        b        | # of balls in count                                                                                                               |
|        s        | # of strikes in count                                                                                                             |
|        o        | # of outs in inning                                                                                                               |
|      stand      | whether batter is left handed or right handed                                                                                     |
|     b_height    | height of the batter                                                                                                              |
|     p_throws    | whether the pitcher is left handed or right handed                                                                                |
|    atbat_des    | summary of the result of the at bat                                                                                               |
|    event_num    | number corresponding to the type of the result of the at bat                                                                      |
|      event      | categorization of result of the at bat (correlates to event_num)                                                                  |
|  home_team_runs | how many runs the home team had at the time of the at bat                                                                         |
|  away_team_runs | how many runs the away team had at the time of the at bat                                                                         |
|   inning_side   | whether it was the top or the bottom of the inning                                                                                |
|      inning     | what inning it was in the game                                                                                                    |
|   batter_name   | name of the batter                                                                                                                |
|   pitcher_name  | name of the pitcher                                                                                                               |
|      date_1     | date of the event (YYYY_MM_DD)                                                                                                    |
|       des       | categorization of the result of the pitch                                                                                         |
|        id       | unique id for individual pitch within an individual game                                                                          |
|     type_bsx    | whether the result of the pitch as a ball (B), strike (S), or ball in play (X)                                                    |
|        x        | x location of the batted ball in feet                                                                                             |
|        y        | y location of the batted ball in feet                                                                                             |
|   start_speed   | initial velocity of the pitch when released from the pitcher's hand (MPH)                                                         |
|    end_speed    | velocity of the pitch when it crosses home plate (MPH) - Number commonly read on radar guns                                       |
|      sz_top     | top-most height of the strikezone in feet for the given batter (measured from ground)                                             |
|      sz_bot     | bottom-most height of the strikezone in feet for the given batter (measured from ground)                                          |
|      pfx_x      | horizontal movement of the pitch in inches                                                                                        |
|      pfx_z      | vertical movement of the pitch in inches                                                                                          |
|        px       | horizontal distance of the pitch from the center of the plate in inches                                                           |
|        pz       | vertical distance of the pitch from the center of the plate in inches                                                             |
|        x0       | vertical distance from the center of the plate, in feet, where the pitch was released                                             |
|        y0       | distance, in feet, from home plate where pitchFx system begins to take initial measurements                                       |
|        z0       | the height, in feet, at which the pitch was released                                                                              |
|       vx0       | the velocity of the pitch in the x direction, in feet per second                                                                  |
|       vy0       | the velocity of the pitch in the y direction, in feet per second                                                                  |
|       vz0       | the velocity of the pitch in the z direction, in feet per second                                                                  |
|        ax       | the acceleration of the pitch in the x direction, in feet per second per second                                                   |
|        ay       | the acceleration of the pitch in the y direction, in feet per second per second                                                   |
|        az       | the acceleration of the pitch in the z direction, in feet per second per second                                                   |
|     break_y     | the distance, in feet, from home plate where pitch achieved its greatest deviation from a straight line                           |
|   break_angle   | the angle, in degrees, from a direct vertical line to the location of the pitch when it crossed home plate                        |
|   break_length  | the distance, in inches, of the deviation of a straight line from the release point to the front of home plate to the actual path |
|    pitch_type   | what type the pitch has been classified as (determined by MLB AM algorithm)                                                       |
| type_confidence | how confident the algorithm was in determining pitch_type (0-1)                                                                   |
|       zone      | which bucketed location the pitch fell into (e.g. within strike zone up and in, outside of zone low and out, etc.)                |
|      nasty      | how difficult this particular pitch was to hit (0-100)                                                                            |
|     spin_dir    | the direction of the spin on the ball                                                                                             |
|    spin_rate    | the rate of the spin of the pitch, in rpm (rotations per minute)                                                                  |
|      on_2b      | playerID of the runner on second base, if there is one present                                                                    |
|      on_1b      | playerID of the runner on first base, if there is one present                                                                     |
|      on_3b      | playerID of the runner on third base, if there is one present                                                                     |
|      count      | the count (<# of balls> - <# of strikes>) of the at bat prior to the pitch being thrown                                           |
|       date      | the current date (YYYY_MM_DD)                                                                                                     |