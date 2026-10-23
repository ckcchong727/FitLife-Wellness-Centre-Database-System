-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 23, 2026 at 09:22 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fitlife_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `class`
--

CREATE TABLE `class` (
  `class_id` int(11) NOT NULL,
  `program_id` int(11) NOT NULL,
  `trainer_id` int(11) NOT NULL,
  `class_date` date NOT NULL,
  `class_start` time NOT NULL,
  `class_end` time NOT NULL,
  `class_status` varchar(15) NOT NULL,
  `class_room` varchar(20) DEFAULT NULL
) ;

--
-- Dumping data for table `class`
--

INSERT INTO `class` (`class_id`, `program_id`, `trainer_id`, `class_date`, `class_start`, `class_end`, `class_status`, `class_room`) VALUES
(6001, 4001, 2002, '2025-10-01', '09:00:00', '10:00:00', 'Completed', 'R1'),
(6002, 4001, 2002, '2025-10-08', '09:00:00', '10:00:00', 'Cancelled', 'R1'),
(6003, 4002, 2001, '2025-10-02', '14:00:00', '15:30:00', 'Completed', 'G1'),
(6004, 4003, 2003, '2025-10-03', '18:00:00', '19:00:00', 'Active', 'S1'),
(6005, 4004, 2001, '2025-10-05', '10:00:00', '11:30:00', 'Completed', 'G2');

-- --------------------------------------------------------

--
-- Table structure for table `class_attendance`
--

CREATE TABLE `class_attendance` (
  `class_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `attendance_status` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `class_attendance`
--

INSERT INTO `class_attendance` (`class_id`, `member_id`, `attendance_status`) VALUES
(6001, 1001, 'Attended'),
(6001, 1003, 'Attended'),
(6003, 1001, 'Attended'),
(6003, 1004, 'Absent'),
(6004, 1002, 'Attended'),
(6005, 1005, 'Attended');

-- --------------------------------------------------------

--
-- Table structure for table `enrolment`
--

CREATE TABLE `enrolment` (
  `enrolment_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `program_id` int(11) NOT NULL,
  `enrolment_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `enrolment`
--

INSERT INTO `enrolment` (`enrolment_id`, `member_id`, `program_id`, `enrolment_date`) VALUES
(7001, 1001, 4001, '2025-01-05'),
(7002, 1001, 4002, '2025-01-12'),
(7003, 1002, 4003, '2025-02-10'),
(7004, 1003, 4001, '2025-08-03'),
(7005, 1004, 4002, '2025-03-20'),
(7006, 1005, 4004, '2025-04-05'),
(7007, 1005, 4003, '2025-04-10');

-- --------------------------------------------------------

--
-- Table structure for table `member`
--

CREATE TABLE `member` (
  `member_id` int(11) NOT NULL,
  `membership_id` int(11) NOT NULL,
  `member_name` varchar(80) NOT NULL,
  `member_contact` varchar(20) DEFAULT NULL,
  `member_email` varchar(80) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `member_gender` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `member`
--

INSERT INTO `member` (`member_id`, `membership_id`, `member_name`, `member_contact`, `member_email`, `date_of_birth`, `member_gender`) VALUES
(1001, 5001, 'Aina Rahman', '012-1111111', 'aina@fitlife.com', '2002-05-10', 'F'),
(1002, 5002, 'Lim Wei Jie', '013-2222222', 'weijie@fitlife.com', '2001-09-18', 'M'),
(1003, 5003, 'Siti Nur', '014-3333333', 'siti@fitlife.com', '2003-12-01', 'F'),
(1004, 5004, 'Jason Tan', '016-4444444', 'jason@fitlife.com', '2000-02-22', 'M'),
(1005, 5005, 'Priya Nair', '017-5555555', 'priya@fitlife.com', '1999-07-07', 'F');

-- --------------------------------------------------------

--
-- Table structure for table `membership`
--

CREATE TABLE `membership` (
  `membership_id` int(11) NOT NULL,
  `duration_month` int(11) NOT NULL CHECK (`duration_month` > 0),
  `membership_status` varchar(20) NOT NULL,
  `membership_type` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `membership`
--

INSERT INTO `membership` (`membership_id`, `duration_month`, `membership_status`, `membership_type`) VALUES
(5001, 12, 'Active', 'Premium'),
(5002, 6, 'Active', 'Basic'),
(5003, 3, 'Expired', 'Student'),
(5004, 12, 'Suspended', 'Basic'),
(5005, 6, 'Active', 'Premium');

-- --------------------------------------------------------

--
-- Table structure for table `membership_enrolment`
--

CREATE TABLE `membership_enrolment` (
  `member_id` int(11) NOT NULL,
  `join_date` date NOT NULL,
  `membership_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `membership_enrolment`
--

INSERT INTO `membership_enrolment` (`member_id`, `join_date`, `membership_id`) VALUES
(1001, '2025-01-01', 5001),
(1002, '2025-02-01', 5002),
(1003, '2025-08-01', 5003),
(1004, '2025-03-15', 5004),
(1005, '2025-04-01', 5005);

-- --------------------------------------------------------

--
-- Table structure for table `membership_payment`
--

CREATE TABLE `membership_payment` (
  `payment_id` int(11) NOT NULL,
  `membership_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `membership_payment`
--

INSERT INTO `membership_payment` (`payment_id`, `membership_id`) VALUES
(8001, 5001),
(8003, 5002),
(8005, 5005);

-- --------------------------------------------------------

--
-- Table structure for table `membership_plan`
--

CREATE TABLE `membership_plan` (
  `membership_type` varchar(20) NOT NULL,
  `membership_fee` decimal(8,2) NOT NULL CHECK (`membership_fee` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `membership_plan`
--

INSERT INTO `membership_plan` (`membership_type`, `membership_fee`) VALUES
('Basic', 80.00),
('Premium', 150.00),
('Student', 60.00);

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `payment_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `payment_date` date NOT NULL,
  `payment_type` varchar(20) NOT NULL,
  `description` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`payment_id`, `member_id`, `payment_date`, `payment_type`, `description`) VALUES
(8001, 1001, '2025-01-01', 'Card', 'Membership Fee'),
(8002, 1001, '2025-01-05', 'Online', 'Program Fee'),
(8003, 1002, '2025-02-01', 'Cash', 'Membership Fee'),
(8004, 1002, '2025-02-10', 'Online', 'Program Fee'),
(8005, 1005, '2025-04-01', 'Card', 'Membership Fee'),
(8006, 1005, '2025-04-05', 'Online', 'Program Fee'),
(8007, 1005, '2025-04-10', 'Online', 'Program Fee');

-- --------------------------------------------------------

--
-- Table structure for table `payment_details`
--

CREATE TABLE `payment_details` (
  `description` varchar(50) NOT NULL,
  `amount` decimal(8,2) NOT NULL CHECK (`amount` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment_details`
--

INSERT INTO `payment_details` (`description`, `amount`) VALUES
('Late Fee', 10.00),
('Membership Fee', 0.00),
('Program Fee', 0.00);

-- --------------------------------------------------------

--
-- Table structure for table `program`
--

CREATE TABLE `program` (
  `program_id` int(11) NOT NULL,
  `duration` int(11) NOT NULL CHECK (`duration` > 0),
  `program_fee` decimal(8,2) NOT NULL CHECK (`program_fee` >= 0),
  `trainer_id` int(11) NOT NULL,
  `program_category_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `program`
--

INSERT INTO `program` (`program_id`, `duration`, `program_fee`, `trainer_id`, `program_category_id`) VALUES
(4001, 8, 120.00, 2002, 3001),
(4002, 10, 180.00, 2001, 3002),
(4003, 6, 100.00, 2003, 3003),
(4004, 12, 220.00, 2001, 3002),
(4005, 6, 90.00, 2002, 3001);

-- --------------------------------------------------------

--
-- Table structure for table `program_category`
--

CREATE TABLE `program_category` (
  `program_category_id` int(11) NOT NULL,
  `program_name` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `program_category`
--

INSERT INTO `program_category` (`program_category_id`, `program_name`) VALUES
(3001, 'Mind & Body'),
(3002, 'Strength'),
(3003, 'Cardio');

-- --------------------------------------------------------

--
-- Table structure for table `program_payment`
--

CREATE TABLE `program_payment` (
  `payment_id` int(11) NOT NULL,
  `program_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `program_payment`
--

INSERT INTO `program_payment` (`payment_id`, `program_id`) VALUES
(8002, 4001),
(8004, 4003),
(8007, 4003),
(8006, 4004);

-- --------------------------------------------------------

--
-- Table structure for table `specialization`
--

CREATE TABLE `specialization` (
  `specialization_id` varchar(50) NOT NULL,
  `specialization_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `specialization`
--

INSERT INTO `specialization` (`specialization_id`, `specialization_name`) VALUES
('SP03', 'Cardio & HIIT'),
('SP04', 'Rehab'),
('SP02', 'Strength & Conditioning'),
('SP01', 'Yoga');

-- --------------------------------------------------------

--
-- Table structure for table `trainer`
--

CREATE TABLE `trainer` (
  `trainer_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `specialization_id` varchar(50) NOT NULL,
  `contact_no` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trainer`
--

INSERT INTO `trainer` (`trainer_id`, `first_name`, `last_name`, `specialization_id`, `contact_no`) VALUES
(2001, 'Amir', 'Hassan', 'SP02', '011-9000001'),
(2002, 'Chloe', 'Wong', 'SP01', '011-9000002'),
(2003, 'Daniel', 'Lee', 'SP03', '011-9000003');

-- --------------------------------------------------------

--
-- Table structure for table `trainer_history`
--

CREATE TABLE `trainer_history` (
  `history_id` int(11) NOT NULL,
  `trainer_id` int(11) NOT NULL,
  `program_category_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL
) ;

--
-- Dumping data for table `trainer_history`
--

INSERT INTO `trainer_history` (`history_id`, `trainer_id`, `program_category_id`, `start_date`, `end_date`) VALUES
(9001, 2002, 3001, '2025-01-01', NULL),
(9002, 2001, 3002, '2025-01-01', NULL),
(9003, 2003, 3003, '2025-01-01', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `trainer_skill`
--

CREATE TABLE `trainer_skill` (
  `trainer_id` int(11) NOT NULL,
  `specialization_id` varchar(50) NOT NULL,
  `certification_level` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trainer_skill`
--

INSERT INTO `trainer_skill` (`trainer_id`, `specialization_id`, `certification_level`) VALUES
(2001, 'SP02', 'Level 2'),
(2001, 'SP04', 'Level 1'),
(2002, 'SP01', 'Level 3'),
(2003, 'SP03', 'Level 2');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `class`
--
ALTER TABLE `class`
  ADD PRIMARY KEY (`class_id`),
  ADD KEY `fk_class_program` (`program_id`),
  ADD KEY `fk_class_trainer` (`trainer_id`),
  ADD KEY `idx_class_date` (`class_date`);

--
-- Indexes for table `class_attendance`
--
ALTER TABLE `class_attendance`
  ADD PRIMARY KEY (`class_id`,`member_id`),
  ADD KEY `fk_ca_member` (`member_id`);

--
-- Indexes for table `enrolment`
--
ALTER TABLE `enrolment`
  ADD PRIMARY KEY (`enrolment_id`),
  ADD UNIQUE KEY `uq_member_program` (`member_id`,`program_id`),
  ADD KEY `idx_enrol_program` (`program_id`);

--
-- Indexes for table `member`
--
ALTER TABLE `member`
  ADD PRIMARY KEY (`member_id`),
  ADD UNIQUE KEY `uq_member_email` (`member_email`),
  ADD KEY `fk_member_membership` (`membership_id`);

--
-- Indexes for table `membership`
--
ALTER TABLE `membership`
  ADD PRIMARY KEY (`membership_id`),
  ADD KEY `fk_membership_type` (`membership_type`);

--
-- Indexes for table `membership_enrolment`
--
ALTER TABLE `membership_enrolment`
  ADD PRIMARY KEY (`member_id`),
  ADD KEY `fk_menr_membership` (`membership_id`);

--
-- Indexes for table `membership_payment`
--
ALTER TABLE `membership_payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `fk_mpay_membership` (`membership_id`);

--
-- Indexes for table `membership_plan`
--
ALTER TABLE `membership_plan`
  ADD PRIMARY KEY (`membership_type`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `fk_payment_member` (`member_id`),
  ADD KEY `fk_payment_desc` (`description`),
  ADD KEY `idx_payment_date` (`payment_date`);

--
-- Indexes for table `payment_details`
--
ALTER TABLE `payment_details`
  ADD PRIMARY KEY (`description`);

--
-- Indexes for table `program`
--
ALTER TABLE `program`
  ADD PRIMARY KEY (`program_id`),
  ADD KEY `fk_program_trainer` (`trainer_id`),
  ADD KEY `idx_program_category` (`program_category_id`);

--
-- Indexes for table `program_category`
--
ALTER TABLE `program_category`
  ADD PRIMARY KEY (`program_category_id`);

--
-- Indexes for table `program_payment`
--
ALTER TABLE `program_payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `fk_ppay_program` (`program_id`);

--
-- Indexes for table `specialization`
--
ALTER TABLE `specialization`
  ADD PRIMARY KEY (`specialization_id`),
  ADD UNIQUE KEY `uq_specialization_name` (`specialization_name`);

--
-- Indexes for table `trainer`
--
ALTER TABLE `trainer`
  ADD PRIMARY KEY (`trainer_id`),
  ADD KEY `fk_trainer_specialization` (`specialization_id`);

--
-- Indexes for table `trainer_history`
--
ALTER TABLE `trainer_history`
  ADD PRIMARY KEY (`history_id`),
  ADD KEY `fk_th_trainer` (`trainer_id`),
  ADD KEY `fk_th_category` (`program_category_id`);

--
-- Indexes for table `trainer_skill`
--
ALTER TABLE `trainer_skill`
  ADD PRIMARY KEY (`trainer_id`,`specialization_id`),
  ADD KEY `fk_tskill_specialization` (`specialization_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `class`
--
ALTER TABLE `class`
  ADD CONSTRAINT `fk_class_program` FOREIGN KEY (`program_id`) REFERENCES `program` (`program_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_class_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainer` (`trainer_id`) ON UPDATE CASCADE;

--
-- Constraints for table `class_attendance`
--
ALTER TABLE `class_attendance`
  ADD CONSTRAINT `fk_ca_class` FOREIGN KEY (`class_id`) REFERENCES `class` (`class_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ca_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `enrolment`
--
ALTER TABLE `enrolment`
  ADD CONSTRAINT `fk_enrol_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_enrol_program` FOREIGN KEY (`program_id`) REFERENCES `program` (`program_id`) ON UPDATE CASCADE;

--
-- Constraints for table `member`
--
ALTER TABLE `member`
  ADD CONSTRAINT `fk_member_membership` FOREIGN KEY (`membership_id`) REFERENCES `membership` (`membership_id`) ON UPDATE CASCADE;

--
-- Constraints for table `membership`
--
ALTER TABLE `membership`
  ADD CONSTRAINT `fk_membership_type` FOREIGN KEY (`membership_type`) REFERENCES `membership_plan` (`membership_type`) ON UPDATE CASCADE;

--
-- Constraints for table `membership_enrolment`
--
ALTER TABLE `membership_enrolment`
  ADD CONSTRAINT `fk_menr_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_menr_membership` FOREIGN KEY (`membership_id`) REFERENCES `membership` (`membership_id`) ON UPDATE CASCADE;

--
-- Constraints for table `membership_payment`
--
ALTER TABLE `membership_payment`
  ADD CONSTRAINT `fk_mpay_membership` FOREIGN KEY (`membership_id`) REFERENCES `membership` (`membership_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mpay_payment` FOREIGN KEY (`payment_id`) REFERENCES `payment` (`payment_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `fk_payment_desc` FOREIGN KEY (`description`) REFERENCES `payment_details` (`description`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payment_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `program`
--
ALTER TABLE `program`
  ADD CONSTRAINT `fk_program_category` FOREIGN KEY (`program_category_id`) REFERENCES `program_category` (`program_category_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_program_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainer` (`trainer_id`) ON UPDATE CASCADE;

--
-- Constraints for table `program_payment`
--
ALTER TABLE `program_payment`
  ADD CONSTRAINT `fk_ppay_payment` FOREIGN KEY (`payment_id`) REFERENCES `payment` (`payment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ppay_program` FOREIGN KEY (`program_id`) REFERENCES `program` (`program_id`) ON UPDATE CASCADE;

--
-- Constraints for table `trainer`
--
ALTER TABLE `trainer`
  ADD CONSTRAINT `fk_trainer_specialization` FOREIGN KEY (`specialization_id`) REFERENCES `specialization` (`specialization_id`) ON UPDATE CASCADE;

--
-- Constraints for table `trainer_history`
--
ALTER TABLE `trainer_history`
  ADD CONSTRAINT `fk_th_category` FOREIGN KEY (`program_category_id`) REFERENCES `program_category` (`program_category_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_th_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainer` (`trainer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `trainer_skill`
--
ALTER TABLE `trainer_skill`
  ADD CONSTRAINT `fk_tskill_specialization` FOREIGN KEY (`specialization_id`) REFERENCES `specialization` (`specialization_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_tskill_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainer` (`trainer_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
