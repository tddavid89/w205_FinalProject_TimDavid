##########################
##########################
#SETUP + DATA COLLECTION
##########################
##########################

args <- commandArgs(TRUE)

#LOAD REQUIRED PACKAGES
library(ggplot2)
library(pitchRx)
library(dplyr)
library(plyr)
library(Hmisc)
library(lattice)

# #DEFINE STRIKE ZONE
# topKzone <- 3.5
# botKzone <- 1.6
# inKzone <- -0.95
# outKzone <- 0.95
# kZone <- data.frame(
#   x=c(inKzone, inKzone, outKzone, outKzone, inKzone),
#   y=c(botKzone, topKzone, topKzone, botKzone, botKzone)
# )

#DETERMINE WHICH XML ITEMS WE NEED + SCRAPE DATA FOR TIME FRAME
files <- c("inning/inning_all.xml", "players.xml", "inning/inning_hit.xml")
#dat <- scrape(start = "2015-09-29", end = "2015-09-29", suffix = files)
#dat <- scrape(start = Sys.Date(), end = Sys.Date() - 1, suffix = files)
dat <- scrape(start = args[1], end = args[1], suffix = files)

##########################
##########################
#DATA MANIPULATION
##########################
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

#SUBSET WHERE PITCHER = FELIX HERNANDEZ
###pitcher_atbats <- subset(dat.atbat, pitcher_name %in% "Vidal Nuno")
pitcher_atbats <- dat.atbat

#RENAME TYPE TO TYPE_BSX
names(dat.pitch)[names(dat.pitch) == "type"] <- "type_bsx"

#JOIN DATAFRAMES PITCHER_ATBATS + PITCH
pitcher <- join(pitcher_atbats, dat.pitch, by = c("num", "url"), type="inner")


#DROP IRRELEVANT COLUMN

keeps <- c('b','s','o','stand','b_height','p_throws','atbat_des','event_num','event','home_team_runs','away_team_runs','inning_side','inning','batter_name','pitcher_name','date','des','id','type_bsx','x','y','start_speed','end_speed','sz_top','sz_bot','pfx_x','pfx_z','px','pz','x0','y0','z0','vx0','vy0','vz0','ax','ay','az','break_y','break_angle','break_length','pitch_type','type_confidence','zone','nasty','spin_dir','spin_rate','on_1b','on_2b','on_3b','count')
pitcher <- pitcher[,(names(pitcher) %in% keeps)]

pitcher$inning_side.1 <- NULL
pitcher$inning.1 <- NULL
pitcher$event_num.1 <- NULL

#SAVE FILE TO LOCAL DIR
write.csv(pitcher,file="/data/w205_test.csv",row.names=FALSE)