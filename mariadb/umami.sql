-- manually created from https://github.com/umami-software/umami/tree/v1.38.0/db/mysql/migrations
-- mariadb-dump --skip-add-drop-table --skip-add-locks --skip-disable-keys --skip-dump-date --skip-tz-utc --skip-comments umami

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_event_old` (
  `event_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_value` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`event_id`),
  KEY `event_old_created_at_idx` (`created_at`),
  KEY `event_old_session_id_idx` (`session_id`),
  KEY `event_old_website_id_idx` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `account_username_key` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

INSERT INTO `account` VALUES (1,'admin','$2b$10$BUli0c.muyCW1ErNJc3jL.vFRFtFJWrT8/GcR4A.sUdCznaXiqFXa',1,'2022-09-14 16:46:03','2022-09-14 16:46:03');
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event` (
  `event_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`event_id`),
  KEY `event_created_at_idx` (`created_at`),
  KEY `event_session_id_idx` (`session_id`),
  KEY `event_website_id_idx` (`website_id`),
  CONSTRAINT `event_session_id_fkey` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON UPDATE CASCADE,
  CONSTRAINT `event_website_id_fkey` FOREIGN KEY (`website_id`) REFERENCES `website` (`website_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_data` (
  `event_data_id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(10) unsigned NOT NULL,
  `event_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`event_data`)),
  PRIMARY KEY (`event_data_id`),
  UNIQUE KEY `event_data_event_id_key` (`event_id`),
  CONSTRAINT `event_data_event_id_fkey` FOREIGN KEY (`event_id`) REFERENCES `event` (`event_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pageview` (
  `view_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `referrer` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`view_id`),
  KEY `pageview_created_at_idx` (`created_at`),
  KEY `pageview_session_id_idx` (`session_id`),
  KEY `pageview_website_id_created_at_idx` (`website_id`,`created_at`),
  KEY `pageview_website_id_idx` (`website_id`),
  KEY `pageview_website_id_session_id_created_at_idx` (`website_id`,`session_id`,`created_at`),
  CONSTRAINT `pageview_session_id_fkey` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON UPDATE CASCADE,
  CONSTRAINT `pageview_website_id_fkey` FOREIGN KEY (`website_id`) REFERENCES `website` (`website_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `session_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_uuid` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `website_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `hostname` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `browser` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `os` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `screen` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language` varchar(35) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `session_session_uuid_key` (`session_uuid`),
  KEY `session_created_at_idx` (`created_at`),
  KEY `session_website_id_idx` (`website_id`),
  CONSTRAINT `session_website_id_fkey` FOREIGN KEY (`website_id`) REFERENCES `website` (`website_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `website` (
  `website_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_uuid` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `domain` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `share_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`website_id`),
  UNIQUE KEY `website_website_uuid_key` (`website_uuid`),
  UNIQUE KEY `website_share_id_key` (`share_id`),
  KEY `website_user_id_idx` (`user_id`),
  CONSTRAINT `website_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `account` (`user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

