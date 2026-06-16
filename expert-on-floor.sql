-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3307
-- Generation Time: May 30, 2026 at 02:27 PM
-- Server version: 8.0.30
-- PHP Version: 8.2.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `expert-on-floor`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int NOT NULL,
  `learner_id` int NOT NULL,
  `expert_id` int NOT NULL,
  `session_type` enum('chat','audio','video') NOT NULL,
  `date` date NOT NULL,
  `time_slot` time NOT NULL,
  `duration_minutes` int NOT NULL,
  `topic` varchar(255) DEFAULT NULL,
  `status` enum('pending_payment','confirmed','completed','cancelled') DEFAULT 'pending_payment',
  `amount` int NOT NULL,
  `razorpay_order_id` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `community_answers`
--

CREATE TABLE `community_answers` (
  `id` int NOT NULL,
  `post_id` int NOT NULL,
  `author_id` int NOT NULL,
  `answer` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `community_posts`
--

CREATE TABLE `community_posts` (
  `id` int NOT NULL,
  `author_id` int NOT NULL,
  `question` text NOT NULL,
  `tag` varchar(50) DEFAULT NULL,
  `answers_count` int DEFAULT '0',
  `likes` int DEFAULT '0',
  `liked_by` json DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `conversations`
--

CREATE TABLE `conversations` (
  `id` int NOT NULL,
  `participant1_id` int NOT NULL,
  `participant2_id` int NOT NULL,
  `last_message` text,
  `last_message_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expert_profiles`
--

CREATE TABLE `expert_profiles` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `title` varchar(150) NOT NULL,
  `category` varchar(50) NOT NULL,
  `experience_years` int NOT NULL,
  `price_per_hour` int NOT NULL,
  `is_available` tinyint(1) DEFAULT '1',
  `skills` json NOT NULL,
  `achievements` json DEFAULT NULL,
  `bio` text,
  `total_sessions` int DEFAULT '0',
  `avg_rating` decimal(2,1) DEFAULT '0.0',
  `total_reviews` int DEFAULT '0',
  `availability` json DEFAULT NULL,
  `verification_status` enum('pending','verified','rejected') DEFAULT 'pending',
  `verification_documents` json DEFAULT NULL,
  `is_featured` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `expert_profiles`
--

INSERT INTO `expert_profiles` (`id`, `user_id`, `title`, `category`, `experience_years`, `price_per_hour`, `is_available`, `skills`, `achievements`, `bio`, `total_sessions`, `avg_rating`, `total_reviews`, `availability`, `verification_status`, `verification_documents`, `is_featured`, `created_at`, `updated_at`) VALUES
(1, 1, 'Senior Software Engineer', 'Technology', 10, 1000, 1, '[\"Node.js\", \"React\", \"MySQL\"]', '[]', 'Expert in backend development', 0, 0.0, 0, NULL, 'pending', NULL, 0, '2026-05-30 13:28:16', '2026-05-30 13:28:16'),
(2, 2, 'Senior Software Engineer', 'Technology', 10, 1000, 1, '[\"Node.js\", \"React\", \"MySQL\"]', '[]', 'Expert in backend development', 0, 0.0, 0, NULL, 'pending', NULL, 0, '2026-05-30 13:33:03', '2026-05-30 13:33:03');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int NOT NULL,
  `conversation_id` int NOT NULL,
  `sender_id` int NOT NULL,
  `text` text,
  `type` enum('text','file','system') DEFAULT 'text',
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `type` enum('booking_confirmed','session_reminder','new_message','review_received','payment_success','roadmap_update') NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int NOT NULL,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `razorpay_order_id` varchar(100) DEFAULT NULL,
  `razorpay_payment_id` varchar(100) DEFAULT NULL,
  `amount` int NOT NULL,
  `status` enum('pending','success','failed','refunded') DEFAULT 'pending',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int NOT NULL,
  `booking_id` int NOT NULL,
  `learner_id` int NOT NULL,
  `expert_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `comment` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roadmaps`
--

CREATE TABLE `roadmaps` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `goal` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `total_weeks` int DEFAULT NULL,
  `steps` json NOT NULL,
  `current_level` enum('beginner','intermediate','advanced') DEFAULT NULL,
  `time_available_weekly` int DEFAULT NULL,
  `progress_percent` int DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('learner','expert','admin') NOT NULL DEFAULT 'learner',
  `profile_image` text,
  `is_email_verified` tinyint(1) DEFAULT '0',
  `refresh_token` text,
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `phone`, `password`, `role`, `profile_image`, `is_email_verified`, `refresh_token`, `last_login`, `created_at`, `updated_at`) VALUES
(1, 'Test Learner', 'learner_1780147696277@test.com', NULL, '$2b$10$X8.K0P12JD8d4WQ8v7fMCesfG.wdF5d5tTp.16Se.LZYrlbyAeCUa', 'expert', NULL, 0, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6ImxlYXJuZXIiLCJpYXQiOjE3ODAxNDc2OTYsImV4cCI6MTc4MjczOTY5Nn0.l3d_2fmnz7f8Ipa2COPD57ATLt3DmXhvDtXjI2JWUjE', '2026-05-30 13:28:16', '2026-05-30 13:28:16', '2026-05-30 13:28:16'),
(2, 'Test Learner', 'learner_1780147982813@test.com', NULL, '$2b$10$nldVxtVeXFyQJNliPUWSsuUcKZrl8vOMjx.fcHRDo3wB9Ug4F3tvK', 'expert', NULL, 0, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Miwicm9sZSI6ImxlYXJuZXIiLCJpYXQiOjE3ODAxNDc5ODMsImV4cCI6MTc4MjczOTk4M30.yNtd9vlLAz8JB8vUnPoT9RVo47t4FIQOyAlFxLrvy_0', '2026-05-30 13:33:03', '2026-05-30 13:33:02', '2026-05-30 13:33:03');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `learner_id` (`learner_id`),
  ADD KEY `expert_id` (`expert_id`);

--
-- Indexes for table `community_answers`
--
ALTER TABLE `community_answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`),
  ADD KEY `author_id` (`author_id`);

--
-- Indexes for table `community_posts`
--
ALTER TABLE `community_posts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `author_id` (`author_id`);

--
-- Indexes for table `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `participant1_id` (`participant1_id`),
  ADD KEY `participant2_id` (`participant2_id`);

--
-- Indexes for table `expert_profiles`
--
ALTER TABLE `expert_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `conversation_id` (`conversation_id`),
  ADD KEY `sender_id` (`sender_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `razorpay_order_id` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_2` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_3` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_4` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_5` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_6` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_7` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_8` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_9` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_10` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_11` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_12` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_13` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_14` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_15` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_16` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_17` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_18` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_19` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_20` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_21` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_22` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_23` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_24` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_25` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_26` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_27` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_28` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_29` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_30` (`razorpay_order_id`),
  ADD UNIQUE KEY `razorpay_order_id_31` (`razorpay_order_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_id` (`booking_id`),
  ADD KEY `learner_id` (`learner_id`),
  ADD KEY `expert_id` (`expert_id`);

--
-- Indexes for table `roadmaps`
--
ALTER TABLE `roadmaps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `email_2` (`email`),
  ADD UNIQUE KEY `email_3` (`email`),
  ADD UNIQUE KEY `email_4` (`email`),
  ADD UNIQUE KEY `email_5` (`email`),
  ADD UNIQUE KEY `email_6` (`email`),
  ADD UNIQUE KEY `email_7` (`email`),
  ADD UNIQUE KEY `email_8` (`email`),
  ADD UNIQUE KEY `email_9` (`email`),
  ADD UNIQUE KEY `email_10` (`email`),
  ADD UNIQUE KEY `email_11` (`email`),
  ADD UNIQUE KEY `email_12` (`email`),
  ADD UNIQUE KEY `email_13` (`email`),
  ADD UNIQUE KEY `email_14` (`email`),
  ADD UNIQUE KEY `email_15` (`email`),
  ADD UNIQUE KEY `email_16` (`email`),
  ADD UNIQUE KEY `email_17` (`email`),
  ADD UNIQUE KEY `email_18` (`email`),
  ADD UNIQUE KEY `email_19` (`email`),
  ADD UNIQUE KEY `email_20` (`email`),
  ADD UNIQUE KEY `email_21` (`email`),
  ADD UNIQUE KEY `email_22` (`email`),
  ADD UNIQUE KEY `email_23` (`email`),
  ADD UNIQUE KEY `email_24` (`email`),
  ADD UNIQUE KEY `email_25` (`email`),
  ADD UNIQUE KEY `email_26` (`email`),
  ADD UNIQUE KEY `email_27` (`email`),
  ADD UNIQUE KEY `email_28` (`email`),
  ADD UNIQUE KEY `email_29` (`email`),
  ADD UNIQUE KEY `email_30` (`email`),
  ADD UNIQUE KEY `email_31` (`email`),
  ADD UNIQUE KEY `email_32` (`email`),
  ADD UNIQUE KEY `email_33` (`email`),
  ADD UNIQUE KEY `email_34` (`email`),
  ADD UNIQUE KEY `email_35` (`email`),
  ADD UNIQUE KEY `email_36` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `community_answers`
--
ALTER TABLE `community_answers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `community_posts`
--
ALTER TABLE `community_posts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expert_profiles`
--
ALTER TABLE `expert_profiles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roadmaps`
--
ALTER TABLE `roadmaps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`learner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `community_answers`
--
ALTER TABLE `community_answers`
  ADD CONSTRAINT `community_answers_ibfk_61` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `community_answers_ibfk_62` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `community_posts`
--
ALTER TABLE `community_posts`
  ADD CONSTRAINT `community_posts_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `conversations`
--
ALTER TABLE `conversations`
  ADD CONSTRAINT `conversations_ibfk_1` FOREIGN KEY (`participant1_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `conversations_ibfk_2` FOREIGN KEY (`participant2_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `expert_profiles`
--
ALTER TABLE `expert_profiles`
  ADD CONSTRAINT `expert_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_31` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_32` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_97` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_98` FOREIGN KEY (`learner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_99` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `roadmaps`
--
ALTER TABLE `roadmaps`
  ADD CONSTRAINT `roadmaps_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
