# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 106.12.107.176 (MySQL 5.7.26-0ubuntu0.16.04.1)
# Database: FilePlay
# Generation Time: 2019-05-10 09:24:57 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table account_table
# ------------------------------------------------------------

DROP TABLE IF EXISTS `account_table`;

CREATE TABLE `account_table` (
  `userId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `nickname` varchar(50) NOT NULL DEFAULT '',
  `portrait` varchar(255) DEFAULT '',
  `gender` int(5) NOT NULL DEFAULT '0',
  `mobile` varchar(30) NOT NULL DEFAULT '',
  `date` datetime NOT NULL,
  `introduce` varchar(512) NOT NULL DEFAULT '',
  `password` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `account_table`
--

LOCK TABLES `account_table` WRITE;
/*!40000 ALTER TABLE `account_table` DISABLE KEYS */;
INSERT INTO `account_table` VALUES (10000,'','',1,'','1970-01-01','','');
/*!40000 ALTER TABLE `account_table` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table attention_fan
# ------------------------------------------------------------

DROP TABLE IF EXISTS `attention_fan`;

CREATE TABLE `attention_fan` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `authorId` int(20) unsigned NOT NULL,
  `userId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `attention_fan`
--

LOCK TABLES `attention_fan` WRITE;
/*!40000 ALTER TABLE `attention_fan` DISABLE KEYS */;
INSERT INTO `attention_fan` VALUES (10000,0,0);
/*!40000 ALTER TABLE `attention_fan` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table comment_table
# ------------------------------------------------------------

DROP TABLE IF EXISTS `comment_table`;

CREATE TABLE `comment_table` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `authorId` int(20) unsigned NOT NULL,
  `content` mediumtext NOT NULL,
  `postDate` datetime NOT NULL,
  `replyId` int(20) unsigned NOT NULL,
  `dynamicId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `comment_table`
--

LOCK TABLES `comment_table` WRITE;
/*!40000 ALTER TABLE `comment_table` DISABLE KEYS */;
INSERT INTO `comment_table` VALUES (10000,0,'','1970-01-01',0,0);
/*!40000 ALTER TABLE `comment_table` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table dynamic_table
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dynamic_table`;

CREATE TABLE `dynamic_table` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `authorId` int(20) unsigned NOT NULL,
  `content` mediumtext NOT NULL,
  `image` varchar(255) DEFAULT '',
  `imageWH` varchar(255) DEFAULT '',
  `postDate` datetime NOT NULL,
  `movieId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `dynamic_table`
--

LOCK TABLES `dynamic_table` WRITE;
/*!40000 ALTER TABLE `dynamic_table` DISABLE KEYS */;
INSERT INTO `dynamic_table` VALUES (10000,0,'','','','1970-01-01',0);
/*!40000 ALTER TABLE `dynamic_table` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table movie_table
# ------------------------------------------------------------

DROP TABLE IF EXISTS `movie_table`;

CREATE TABLE `movie_table` (
  `movieId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `tmdbmovieId` int(20) unsigned NOT NULL,
  `title` varchar(255) DEFAULT '',
  `original_title` varchar(255) DEFAULT '',
  `vote_average` varchar(255) DEFAULT '',
  `vote_count` varchar(255) DEFAULT '',
  `release_date` varchar(255) DEFAULT '',
  `poster_path` varchar(255) DEFAULT '',
  `genreids` varchar(255) DEFAULT '',
  `isEpisode` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`movieId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `movie_table`
--

LOCK TABLES `movie_table` WRITE;
/*!40000 ALTER TABLE `movie_table` DISABLE KEYS */;
INSERT INTO `movie_table` VALUES (10000,0,'','','','','','','',0);
/*!40000 ALTER TABLE `movie_table` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table praise_comment
# ------------------------------------------------------------

DROP TABLE IF EXISTS `praise_comment`;

CREATE TABLE `praise_comment` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `commentId` int(20) unsigned NOT NULL,
  `authorId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `praise_comment`
--

LOCK TABLES `praise_comment` WRITE;
/*!40000 ALTER TABLE `praise_comment` DISABLE KEYS */;
INSERT INTO `praise_comment` VALUES (10000,0,0);
/*!40000 ALTER TABLE `praise_comment` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table praise_dynamic
# ------------------------------------------------------------

DROP TABLE IF EXISTS `praise_dynamic`;

CREATE TABLE `praise_dynamic` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `dynamicId` int(20) unsigned NOT NULL,
  `authorId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `praise_dynamic`
--

LOCK TABLES `praise_dynamic` WRITE;
/*!40000 ALTER TABLE `praise_dynamic` DISABLE KEYS */;
INSERT INTO `praise_dynamic` VALUES (10000,0,0);
/*!40000 ALTER TABLE `praise_dynamic` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table report_comment
# ------------------------------------------------------------

DROP TABLE IF EXISTS `report_comment`;

CREATE TABLE `report_comment` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `commentId` int(20) unsigned NOT NULL,
  `authorId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `report_comment`
--

LOCK TABLES `report_comment` WRITE;
/*!40000 ALTER TABLE `report_comment` DISABLE KEYS */;
INSERT INTO `report_comment` VALUES (10000,0,0);
/*!40000 ALTER TABLE `report_comment` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table report_dynamic
# ------------------------------------------------------------

DROP TABLE IF EXISTS `report_dynamic`;

CREATE TABLE `report_dynamic` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `dynamicId` int(20) unsigned NOT NULL,
  `authorId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `report_dynamic`
--

LOCK TABLES `report_dynamic` WRITE;
/*!40000 ALTER TABLE `report_dynamic` DISABLE KEYS */;
INSERT INTO `report_dynamic` VALUES (10000,0,0);
/*!40000 ALTER TABLE `report_dynamic` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table report_user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `report_user`;

CREATE TABLE `report_user` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `authorId` int(20) unsigned NOT NULL,
  `userId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `report_user`
--

LOCK TABLES `report_user` WRITE;
/*!40000 ALTER TABLE `report_user` DISABLE KEYS */;
INSERT INTO `report_user` VALUES (10000,0,0);
/*!40000 ALTER TABLE `report_user` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table want_movie
# ------------------------------------------------------------

DROP TABLE IF EXISTS `want_movie`;

CREATE TABLE `want_movie` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `movieId` int(20) unsigned NOT NULL,
  `userId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `want_movie`
--

LOCK TABLES `want_movie` WRITE;
/*!40000 ALTER TABLE `want_movie` DISABLE KEYS */;
INSERT INTO `want_movie` VALUES (10000,0,0);
/*!40000 ALTER TABLE `want_movie` ENABLE KEYS */;
UNLOCK TABLES;

# Dump of table watch_movie
# ------------------------------------------------------------

DROP TABLE IF EXISTS `watch_movie`;

CREATE TABLE `watch_movie` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `movieId` int(20) unsigned NOT NULL,
  `userId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `watch_movie`
--

LOCK TABLES `watch_movie` WRITE;
/*!40000 ALTER TABLE `watch_movie` DISABLE KEYS */;
INSERT INTO `watch_movie` VALUES (10000,0,0);
/*!40000 ALTER TABLE `watch_movie` ENABLE KEYS */;
UNLOCK TABLES;


/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
