-- MySQL dump 10.13  Distrib 5.7.25, for osx10.14 (x86_64)
--
-- Host: localhost    Database: fileplay
-- ------------------------------------------------------
-- Server version	5.7.25

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_table`
--

DROP TABLE IF EXISTS `account_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_table` (
  `userId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `nickname` varchar(50) NOT NULL DEFAULT '',
  `portrait` varchar(255) DEFAULT '',
  `gender` int(5) NOT NULL DEFAULT '0',
  `mobile` varchar(30) NOT NULL DEFAULT '',
  `date` datetime NOT NULL,
  `introduce` varchar(512) NOT NULL DEFAULT '',
  `password` varchar(256) CHARACTER SET latin1 NOT NULL DEFAULT '',
  PRIMARY KEY (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=10001 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_table`
--

LOCK TABLES `account_table` WRITE;
/*!40000 ALTER TABLE `account_table` DISABLE KEYS */;
INSERT INTO `account_table` VALUES (10000,'少爷','',1,'15217224985','2019-03-09 11:08:01','错过一时 错过一生','_ä³¿(¦!Ç;îÁ£a');
/*!40000 ALTER TABLE `account_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attention_fan`
--

DROP TABLE IF EXISTS `attention_fan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attention_fan` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `authorId` int(20) unsigned NOT NULL,
  `userId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attention_fan`
--

LOCK TABLES `attention_fan` WRITE;
/*!40000 ALTER TABLE `attention_fan` DISABLE KEYS */;
/*!40000 ALTER TABLE `attention_fan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_table`
--

DROP TABLE IF EXISTS `comment_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment_table` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `authorId` int(20) unsigned NOT NULL,
  `content` mediumtext NOT NULL,
  `postDate` datetime NOT NULL,
  `replyId` int(20) unsigned NOT NULL,
  `dynamicId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_table`
--

LOCK TABLES `comment_table` WRITE;
/*!40000 ALTER TABLE `comment_table` DISABLE KEYS */;
INSERT INTO `comment_table` VALUES (1,10000,'‘Good’','2019-05-09 16:31:33',0,10014);
/*!40000 ALTER TABLE `comment_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_table`
--

DROP TABLE IF EXISTS `dynamic_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_table` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `authorId` int(20) unsigned NOT NULL,
  `content` mediumtext NOT NULL,
  `image` varchar(255) DEFAULT '',
  `imageWH` varchar(255) DEFAULT '',
  `postDate` datetime NOT NULL,
  `movieId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10015 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_table`
--

LOCK TABLES `dynamic_table` WRITE;
/*!40000 ALTER TABLE `dynamic_table` DISABLE KEYS */;
INSERT INTO `dynamic_table` VALUES (10000,10000,'错过一时 错过一生','','','2019-03-30 22:37:27',10003),(10013,10000,'‘我们的爱 过了就不会回来‘’','','','2019-03-30 23:17:15',10003),(10014,10000,'Test ‘results’','','','2019-04-19 01:09:04',10003);
/*!40000 ALTER TABLE `dynamic_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movie_table`
--

DROP TABLE IF EXISTS `movie_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=10005 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movie_table`
--

LOCK TABLES `movie_table` WRITE;
/*!40000 ALTER TABLE `movie_table` DISABLE KEYS */;
INSERT INTO `movie_table` VALUES (10003,9762,'舞出我人生','Step Up','6.8','2106','2006-08-11','/7EfV3BxvtTibNhXNs2O3bvKNiFL.jpg','10402,18,10749,80',0),(10004,37661,'Icon','Icon','6.2','6','2005-01-01','/gHL1eEvri7bTq0lDh5Ggasl3MpX.jpg','10770,28,18,53',0);
/*!40000 ALTER TABLE `movie_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `praise_comment`
--

DROP TABLE IF EXISTS `praise_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `praise_comment` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `commentId` int(20) unsigned NOT NULL,
  `authorId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `praise_comment`
--

LOCK TABLES `praise_comment` WRITE;
/*!40000 ALTER TABLE `praise_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `praise_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `praise_dynamic`
--

DROP TABLE IF EXISTS `praise_dynamic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `praise_dynamic` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `dynamicId` int(20) unsigned NOT NULL,
  `authorId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10004 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `praise_dynamic`
--

LOCK TABLES `praise_dynamic` WRITE;
/*!40000 ALTER TABLE `praise_dynamic` DISABLE KEYS */;
INSERT INTO `praise_dynamic` VALUES (10003,10000,10000);
/*!40000 ALTER TABLE `praise_dynamic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_comment`
--

DROP TABLE IF EXISTS `report_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_comment` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `commentId` int(20) unsigned NOT NULL,
  `authorId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_comment`
--

LOCK TABLES `report_comment` WRITE;
/*!40000 ALTER TABLE `report_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_dynamic`
--

DROP TABLE IF EXISTS `report_dynamic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_dynamic` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `dynamicId` int(20) unsigned NOT NULL,
  `authorId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_dynamic`
--

LOCK TABLES `report_dynamic` WRITE;
/*!40000 ALTER TABLE `report_dynamic` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_dynamic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_user`
--

DROP TABLE IF EXISTS `report_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_user` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `authorId` int(20) unsigned NOT NULL,
  `userId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_user`
--

LOCK TABLES `report_user` WRITE;
/*!40000 ALTER TABLE `report_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `want_movie`
--

DROP TABLE IF EXISTS `want_movie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `want_movie` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `movieId` int(20) unsigned NOT NULL,
  `userId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `want_movie`
--

LOCK TABLES `want_movie` WRITE;
/*!40000 ALTER TABLE `want_movie` DISABLE KEYS */;
/*!40000 ALTER TABLE `want_movie` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `watch_movie`
--

DROP TABLE IF EXISTS `watch_movie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `watch_movie` (
  `objectId` int(20) unsigned NOT NULL AUTO_INCREMENT,
  `movieId` int(20) unsigned NOT NULL,
  `userId` int(20) unsigned NOT NULL,
  PRIMARY KEY (`objectId`)
) ENGINE=InnoDB AUTO_INCREMENT=10001 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `watch_movie`
--

LOCK TABLES `watch_movie` WRITE;
/*!40000 ALTER TABLE `watch_movie` DISABLE KEYS */;
INSERT INTO `watch_movie` VALUES (10000,10003,10000);
/*!40000 ALTER TABLE `watch_movie` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-05-10 11:28:38
