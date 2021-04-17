-- phpMyAdmin SQL Dump
-- version 4.9.5deb2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 03, 2021 at 05:54 PM
-- Server version: 8.0.23-0ubuntu0.20.04.1
-- PHP Version: 7.4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `senior_project`
--
CREATE DATABASE IF NOT EXISTS `senior_project` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `senior_project`;

-- --------------------------------------------------------

--
-- Table structure for table `Backorder`
--

CREATE TABLE `Backorder` (
  `backorder_id` int NOT NULL,
  `Serial_Number` varchar(4) COLLATE utf8_unicode_ci NOT NULL,
  `backorder_qty` int NOT NULL,
  `backorder_status` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `order_date` datetime NOT NULL,
  `total_amount` double NOT NULL,
  `customer_id` varchar(5) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `Backorder`
--

INSERT INTO `Backorder` (`backorder_id`, `Serial_Number`, `backorder_qty`, `backorder_status`, `order_date`, `total_amount`, `customer_id`) VALUES
(1, 'p001', 1, 'unfilled', '2021-03-22 18:24:23', 1700, 'C0001'),
(2, 'p005', 10, 'unfilled', '2021-03-23 17:49:20', 45000, 'C0012'),
(3, 'p005', 10, 'unfilled', '2021-03-23 17:52:51', 45000, 'C0012'),
(4, 'p005', 5, 'filled', '2021-03-23 17:53:06', 22500, 'C0003'),
(5, 'p005', 5, 'filled', '2021-03-23 17:53:36', 22500, 'C0003'),
(6, 'p005', 5, 'filled', '2021-03-23 17:53:50', 22500, 'C0003'),
(7, 'p005', 5, 'filled', '2021-03-23 17:54:12', 22500, 'C0003'),
(8, 'p005', 5, 'filled', '2021-03-23 17:54:25', 22500, 'C0003'),
(9, 'p005', 5, 'unfilled', '2021-03-23 17:55:26', 22500, 'C0003'),
(10, 'p001', 5, 'filled', '2021-03-24 17:55:40', 9000, 'C0002'),
(11, 'p004', 5, 'unfilled', '2021-03-24 18:11:27', 11000, 'C0002'),
(12, 'p004', 10, 'unfilled', '2021-03-24 18:22:44', 22000, 'C0003');

-- --------------------------------------------------------

--
-- Table structure for table `Claim`
--

CREATE TABLE `Claim` (
  `Claim_ID` int NOT NULL,
  `Customer_id` varchar(6) NOT NULL,
  `Receipt_id` int NOT NULL,
  `Claim_date` datetime NOT NULL,
  `Claim_description` longtext NOT NULL,
  `Claim_Status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Claim`
--

INSERT INTO `Claim` (`Claim_ID`, `Customer_id`, `Receipt_id`, `Claim_date`, `Claim_description`, `Claim_Status`) VALUES
(1, 'null', 1, '2021-03-28 18:32:22', 'broken', 'rejected'),
(2, 'null', 1, '2021-03-28 18:34:26', '1', 'approved'),
(3, 'null', 1, '2021-03-28 18:35:00', '...', 'approved'),
(4, 'null', 1, '2021-03-28 18:36:15', '...', 'approved'),
(5, 'null', 1, '2021-03-28 18:38:49', '...', 'approved'),
(6, 'C0012', 3, '2021-03-28 20:51:16', '....', 'processing'),
(7, 'C0003', 2, '2021-03-29 15:52:54', 'The product is malfunction.', 'processing');

-- --------------------------------------------------------

--
-- Table structure for table `Claim_detail`
--

CREATE TABLE `Claim_detail` (
  `Claim_detail_id` int NOT NULL,
  `Claim_id` int NOT NULL,
  `Serial_Number` varchar(5) COLLATE utf8_unicode_ci NOT NULL,
  `qty` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `Claim_detail`
--

INSERT INTO `Claim_detail` (`Claim_detail_id`, `Claim_id`, `Serial_Number`, `qty`) VALUES
(1, 1, 'p008', 1),
(2, 1, 'p007', 1),
(3, 2, 'p008', 1),
(4, 2, 'p007', 1),
(5, 3, 'p007', 1),
(6, 4, 'p007', 1),
(7, 5, 'p007', 1),
(8, 6, 'p001', 1),
(9, 7, 'p005', 5);

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `Customer_ID` varchar(5) NOT NULL,
  `Customer_Name` text NOT NULL,
  `Tel` text NOT NULL,
  `Address` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`Customer_ID`, `Customer_Name`, `Tel`, `Address`) VALUES
('C0001', 'อู่ไฮเทคยนต์', '042-811-723', '110 ถ.มลิวรรณ ต.นาอาน อ.เมือง จ.เลย 42000'),
('C0002', 'อู่ต๋องเจริญยนต์', '089-273-6343', '239 ม.6 ถ.มลิวรรณ ต.นาอาน อ.เมือง จ.เลย 42000'),
('C0003', 'อู่ปรีดาเซอร์วิส', '042-834-339', '92/26 ถ.เลย-ด่านซ้าย ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0004', 'อู่ชาญกิจการช่าง', '042-834-109', '343 ถ.เลย-ด่านซ้าย ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0005', 'อู่ศิริชัย', '042-834-971', '177 ถ.เลย-ด่านซ้าย ต.กุดป่อง อ.เมืองเลย จ.เลย 42000'),
('C0006', 'อู่พลการช่าง', '084-283-5017', '334/1 ถ.เลย-เชียงคาน ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0007', 'อู่จิตรเจริญ', '042-833-345', '272 ถ.มลิวรรณ ต.นาอาน อ.เมือง จ.เลย 42000'),
('C0008', 'อู่แก่นสยามเซอร์วิส', '042-832-069', '44 ม.10 ถ.มลิวรรณ ต.นาอาน อ.เมือง จ.เลย 42000'),
('C0009', 'บริษัท เลยรวมช่าง 1987 จำกั', '042-811-453', '27/15-6 ถ.มลิวรรณ ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0010', 'ห้างหุ้นส่วนจำกัด เมืองเลย อาณาจักรยนต์', '042-812-324', '847 ถ.ร่วมใจ ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0011', 'ร้าน เจริญสมบัติ', '042-813-008', '18/11-3 ถ.นกแก้ว ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0012', 'บริษัท ไจแอนท์ ร๊อค 1990 จำกัด', '086-451-3755', '188 ม.8 ต.เอราวัณ อ.เอราวัณ จ.เลย 42220'),
('C0013', 'บริษัท สุรัตน์การศิลา จำกัด', '042-800-120', '40 ถ.สถล-เชียงคาน ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0014', 'ร้าน ไทยอุดมพาณิชย์', '042-811-167', '41 ถ.เจริญรัฐ ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0015', 'ร้าน ทวีโชค', '042-811-130', '23/2 ถ.ร่วมใจ ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0016', 'ห้างหุ้นส่วนจำกัด เลขวิสุทธิ์', '042-811-568', '75 ม. 6 ถ.มลิวรรณ ต.นาอาน อ.เมือง จ.เลย 42000'),
('C0017', 'ร้าน สหกิจออโต้เซอร์วิส', '042-861-835', '1/39 ถ.มลิวรรณ ต.กุดป่อง อ.เมือง จ.เลย 42000'),
('C0018', 'Jirayu Janlert', '0616491304', 'Bangkok 10530'),
('C0019', 'สิงโต', '0616491304', '92/6 Floraville Bangkok'),
('C0020', 'Jirayu', '0813580103', 'Chiangmai'),
('C0021', 'Singto', '0813580103', 'Bangkok'),
('C0022', 'singto2', '0813580103', 'Bangkok'),
('C0023', 'pla', '002827227', 'hshshshs');

-- --------------------------------------------------------

--
-- Table structure for table `customer_order`
--

CREATE TABLE `customer_order` (
  `Order_Id` int NOT NULL,
  `Order_date` datetime DEFAULT NULL,
  `Total_Amount` double NOT NULL,
  `Customer_id` varchar(5) DEFAULT NULL,
  `Order_status` varchar(10) NOT NULL,
  `receipt_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `customer_order`
--

INSERT INTO `customer_order` (`Order_Id`, `Order_date`, `Total_Amount`, `Customer_id`, `Order_status`, `receipt_id`) VALUES
(1, '2021-03-28 16:59:46', 14500, 'null', 'Completed', 1),
(2, '2021-03-28 18:42:35', 4500, 'C0003', 'Completed', 2),
(3, '2021-03-28 20:49:54', 18600, 'C0012', 'Completed', 3),
(4, '2021-03-30 15:57:31', 4300, 'null', 'Completed', 4),
(5, '2021-03-30 19:25:08', 9000, 'null', 'Completed', 5),
(6, '2021-03-30 20:36:28', 28800, 'null', 'Completed', 6),
(7, '2021-03-30 20:38:44', 4300, 'C0004', 'Completed', 7),
(8, '2021-04-03 14:24:32', 8800, 'C0003', 'Completed', 8),
(9, '2021-04-03 15:18:48', 35800, 'null', 'Completed', 9),
(10, '2021-04-03 19:30:26', 4620, 'null', 'Completed', NULL),
(11, '2021-04-03 20:28:12', 18600, 'C0012', 'Completed', 10),
(12, '2021-04-03 22:31:16', 5000, 'null', 'Completed', 11),
(13, '2021-04-03 23:28:36', 6100, 'C0004', 'Completed', 12),
(14, '2021-04-04 00:44:03', 4800, 'null', 'Completed', 13);

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `order_id` int NOT NULL,
  `order_detail_id` int NOT NULL,
  `serial_number` varchar(4) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `qty` int NOT NULL,
  `line_total` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `order_details`
--

INSERT INTO `order_details` (`order_id`, `order_detail_id`, `serial_number`, `qty`, `line_total`) VALUES
(1, 1, 'p008', 1, 5000),
(1, 2, 'p007', 1, 3000),
(1, 3, 'p012', 1, 6500),
(2, 4, 'p005', 5, 4500),
(3, 5, 'p001', 1, 1800),
(3, 6, 'p010', 1, 16800),
(4, 7, 'p001', 1, 1800),
(4, 8, 'p002', 1, 2500),
(5, 9, 'p009', 2, 9000),
(6, 10, 'p010', 1, 16800),
(6, 11, 'p011', 1, 6500),
(6, 12, 'p013', 1, 5500),
(7, 13, 'p001', 1, 1800),
(7, 14, 'p002', 1, 2500),
(8, 15, 'p005', 5, 4500),
(8, 16, 'p002', 1, 2500),
(8, 17, 'p001', 1, 1800),
(9, 18, 'p029', 1, 30000),
(9, 19, 'p037', 1, 1800),
(9, 20, 'p023', 1, 4000),
(10, 21, 'p041', 1, 3000),
(10, 22, 'p034', 1, 300),
(10, 23, 'p081', 1, 1200),
(10, 24, 'p088', 1, 120),
(11, 25, 'p001', 1, 1800),
(11, 26, 'p010', 1, 16800),
(12, 27, 'p008', 1, 5000),
(13, 28, 'p001', 2, 3600),
(13, 29, 'p002', 1, 2500),
(14, 30, 'p001', 1, 1800),
(14, 31, 'p007', 1, 3000);

-- --------------------------------------------------------

--
-- Table structure for table `product_list`
--

CREATE TABLE `product_list` (
  `Serial_Number` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Product_Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Cost` double NOT NULL,
  `Selling_Price` double NOT NULL,
  `pics` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Details` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_list`
--

INSERT INTO `product_list` (`Serial_Number`, `Category`, `Product_Name`, `Cost`, `Selling_Price`, `pics`, `Details`) VALUES
('p001', 'ก้านเกียร์ 4', 'ก้านเกียร์ 4 HINO EL100 ', 1440, 1800, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gangear4.png', 'ยี่ห้อรถ: HINO\r\nรุ่น: EL100\r\nผลิตที่ : JAPAN\r\nลักษณะ: 22ฟัน ละเอียด'),
('p002', 'ก้านเกียร์ 4', 'ก้านเกียร์ 4 HINO HO7D #4230', 1800, 2500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gangear4.png', 'ยี่ห้อรถ: HINO\r\nรุ่น: HO7D\r\nผลิตที่ : JAPAN\r\nลักษณะ: 25 ฟัน'),
('p003', 'ก้านเกียร์ 4', 'ก้านเกียร์ 4 HINO KR ', 1200, 1500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gangear4.png', 'ยี่ห้อรถ: HINO\r\nรุ่น: KR\r\nผลิตที่ : JAPAN\r\nลักษณะ: 22 ฟัน ไม่มีร่องน้ำมัน'),
('p004', 'ก้านเกียร์ 4', 'ก้านเกียร์ 4 HINO ED100 ', 1800, 2200, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gangear4.png', 'ยี่ห้อรถ: HINO\r\nรุ่น: ED100\r\nผลิตที่ : JAPAN\r\nลักษณะ: 21 ฟัน'),
('p005', 'เฟืองเกียร์ 5', 'เฟืองเกียร์ 5 HINO SUMO #2170', 2400, 4500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gear5.png', 'ยี่ห้อรถ: HINO\r\nรุ่น: SUMO\r\nผลิตที่ : JAPAN\r\nลักษณะ: 27 ฟัน'),
('p006', 'เฟืองเกียร์ 5', 'เฟืองเกียร์ 5 HINO SUMO 26 ฟัน #33337-2110', 2400, 4500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gear5.png', 'No data'),
('p007', 'เฟืองเกียร์ 5', 'เฟืองเกียร์ 5 KT725 25 ฟัน #33337-1200', 2640, 3000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gear5.png', 'No data'),
('p008', 'เฟืองเกียร์ 5', 'เฟืองเกียร์ 5 HINO SUMO 7 เกียร์ 27 ฟัน #2591', 1500, 5000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gear5.png', 'No data'),
('p009', 'เฟืองเกียร์ 5', 'เฟืองเกียร์ 5 EL100 27 ฟัน เฉียง 33334-1431', 2400, 4500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gear5.png', 'No data'),
('p010', 'เทอร์โบ', 'เทอร์โบ JO5C F-DISESEL', 14400, 16800, 'https://storage.googleapis.com/first_singto_bucket/senior_project/turbo.jpg', 'No data'),
('p011', 'ราวบน', 'ราวบน SUMO ELV-1420', 5400, 6500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/up.png', 'No data'),
('p012', 'ราวบน', 'ราวบน SUMO 221', 3600, 6500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/up.png', 'No data'),
('p013', 'ราวบน', 'ราวบน FB จ้าวพยัคฆ์', 3600, 5500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/up.png', 'No data'),
('p014', 'ราวบน', 'ราวบน EL100 7 เกียร์ 33311-1753 ELV-1470', 6200, 7000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/up.png', 'No data'),
('p015', 'ราวบน', 'ราวบน สิงห์ไฮเทค #33321-2191', 4560, 6500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/up.png', 'No data'),
('p016', 'ลูกหมาก', 'ลูกหมาก ISUZU Rocky ซ้าย', 960, 1700, 'https://storage.googleapis.com/first_singto_bucket/senior_project/lookmark.jpg', 'No data'),
('p017', 'ลูกหมาก', 'ลูกหมาก ISUZU Rocky ขวา', 960, 1700, 'https://storage.googleapis.com/first_singto_bucket/senior_project/lookmark.jpg', 'No data'),
('p018', 'ก้านเกียร์ 4', 'ก้านเกียร์ 4 KS21 100 แรง', 1440, 1800, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gangear4.png', 'No data'),
('p019', 'ก้านเกียร์ 4', 'ก้านเกียร์ 4 KS22 110 แรง', 1440, 1800, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gangear4.png', 'No data'),
('p020', 'เฟืองเกียร์ 5', 'เฟืองเกียร์ 5 มังกร ล่างใหญ่ 47 ฟัน ELV-538', 720, 1300, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gear5.png', 'No data'),
('p021', 'เฟืองเกียร์ 5', 'เฟืองเกียร์ 5 มังกร บนเล็ก 25 ฟัน ELV-537', 1200, 1500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gear5.png', 'No data'),
('p022', 'เฟืองตัวล่าง', 'เฟืองตัวล่าง สโลว์ ISUZU JCM 34 ฟัน', 3000, 4500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/slowgear.png', 'No data'),
('p023', 'เฟืองตัวล่าง', 'เฟืองตัวล่าง สโลว์อินเตอร์ 3สปีด 27 ฟัน เล็ก', 3000, 4000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/slowgear.png', 'No data'),
('p024', 'เฟืองตัวล่าง', 'เฟืองตัวล่าง สโลว์อินเตอร์ 4สปีด 27 ฟัน บาง', 3000, 4500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/slowgear.png', 'No data'),
('p025', 'เฟืองตัวล่าง', 'เฟืองตัวล่าง สโลว์อินเตอร์ เล็ก 29 ฟัน เฉียง', 3360, 4500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/slowgear.png', 'No data'),
('p026', 'เฟืองตัวล่าง', 'เฟืองตัวล่าง สโลว์อินเตอร์ กลาง 34 ฟัน เฉียง', 3360, 4500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/slowgear.png', 'No data'),
('p027', 'เทอร์โบ', 'เทอร์โบ R/K 6BG  เลี้ยงน้ำ F-DISESEL', 12000, 14000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/turbo.jpg', 'No data'),
('p028', 'เทอร์โบ', 'เทอร์โบ ISUZU R/K แมคโคร (6BD1T) เล็ก F-DISESEL', 14400, 16000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/turbo.jpg', 'No data'),
('p029', 'เทอร์โบ', 'เทอร์โบ ISUZU DECA 320 F-DISESEL', 27600, 30000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/turbo.jpg', 'No data'),
('p030', 'เทอร์โบ', 'เทอร์โบ มังกร TFR 3000 เลี้ยงน้ำ #4101024 F-DISESEL', 7800, 11000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/turbo.jpg', 'No data'),
('p031', 'ราวล่าง', 'ราวล่าง สโลว์ ISUZU JCM 21 ฟัน มีร่องลิ่ม', 3000, 4800, '', 'No data'),
('p032', 'ราวล่าง', 'ราวล่าง สโลว์ ISUZU JCM 20 ฟัน', 3000, 5400, 'https://storage.googleapis.com/first_singto_bucket/senior_project/down.png', 'No data'),
('p033', 'เฟืองเกียร์ 1', 'เฟืองเกียร์ 1 FUSO แคนเตอร์ 115', 1560, 1900, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gear1.png', 'No data'),
('p034', 'กากบาท', 'กากบาท มิตซู แคนเตอร์ 100 แรง', 240, 300, 'https://storage.googleapis.com/first_singto_bucket/senior_project/x.jpg', 'No data'),
('p035', 'ราวล่าง', 'ราวล่าง Starda 2800 ELV-1511/4', 2160, 2500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/down.png', 'No data'),
('p036', 'ราวล่าง', 'ราวล่าง Starda 2500 ELV-1511 มีเส้น', 2160, 2500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/down.png', 'No data'),
('p037', 'ลูกหมาก', 'ลูกหมาก NISSAN รูเล็ก 37 มม. ขวา', 960, 1800, 'https://storage.googleapis.com/first_singto_bucket/senior_project/lookmark.jpg', 'No data'),
('p038', 'ลูกหมาก', 'ลูกหมาก NISSAN รูเล็ก 37 มม. ซ้าย', 960, 1800, 'https://storage.googleapis.com/first_singto_bucket/senior_project/lookmark.jpg', 'No data'),
('p039', 'ไส้เกียร์ร่วม', 'ไส้เกียร์ร่วม NISSAN CW (4-5) หยาบ', 2160, 2600, 'https://storage.googleapis.com/first_singto_bucket/senior_project/gearruam.png', 'No data'),
('p040', 'ไส้พาวเวอร์', 'ไส้พาวเวอร์ NISSAN PE 28 มิล 18ร่อง #14714-99018', 1200, 3000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/power.png', 'No data'),
('p041', 'ไส้พาวเวอร์', 'ไส้พาวเวอร์ NISSAN 20 มิล 10 ร่อง #44306-1090', 1200, 3000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/power.png', 'No data'),
('p042', 'ไส้พาวเวอร์', 'ไส้พาวเวอร์ NISSAN 30 มิล 18 ร่อง #14714-99018', 1200, 3000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/power.png', 'No data'),
('p043', 'ไส้พาวเวอร์', 'ไส้พาวเวอร์ NISSAN 23 มิล 18 ร่อง #14714-99100', 1200, 3000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/power.png', 'No data'),
('p044', 'ไส้พาวเวอร์', 'ไส้พาวเวอร์ NISSAN 23 มิล 10 ร่อง #14714-99100A', 1200, 3000, 'https://storage.googleapis.com/first_singto_bucket/senior_project/power.png', 'No data'),
('p045', 'ถ่านไดชาร์ท', 'กาแลนท์ จีทีโอ 1700, เอฟทีโอ 1600', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p046', 'ถ่านไดชาร์ท', 'กาแลนท์ ซิกม่า 2000 จีเอส', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p047', 'ถ่านไดชาร์ท', 'แลนเซอร์ 1400, เอ 72, 75', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p048', 'ถ่านไดชาร์ท', 'แอล 200', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p049', 'ถ่านไดชาร์ท', 'แลนเซอร์ 1600 จีเอส', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p050', 'ถ่านไดชาร์ท', 'กาแลนท์ ซิกม่า 1600', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p051', 'ถ่านไดชาร์ท', 'กาแลนท์ 1600 เอ 121', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p052', 'ถ่านไดชาร์ท', 'แคนเตอร์ ที 200, 220 ซี, เอฟอี 100, 120', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p053', 'ถ่านไดชาร์ท', 'ฟูโช่ ดั๊ม ทรัก ดี 320, ดี 200', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p054', 'ถ่านไดชาร์ท', 'ฟูโช่ ใช้งานหนัก เอฟเอ็ม 104, เอฟที 318', 30, 60, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daicharge.jpg', 'No data'),
('p055', 'ถ่านไดสตาร์ท', 'ดัทสัน 1300', 65, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daistart.jpg', 'No data'),
('p056', 'ถ่านไดสตาร์ท', 'ซันนี่ บี 110-1200', 65, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daistart.jpg', 'No data'),
('p057', 'ถ่านไดสตาร์ท', 'ซันนี่ 1400 บี 310', 65, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daistart.jpg', 'No data'),
('p058', 'ถ่านไดสตาร์ท', 'บลูเบิร์ด 2000', 65, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daistart.jpg', 'No data'),
('p059', 'ถ่านไดสตาร์ท', 'ซันนี่ อี บี 310', 65, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daistart.jpg', 'No data'),
('p060', 'ถ่านไดสตาร์ท', 'พัลซ่า อี-วายเอ็น 10', 65, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daistart.jpg', 'No data'),
('p061', 'ถ่านไดสตาร์ท', 'ซันนี่ 1000 บี 10', 50, 80, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daistart.jpg', 'No data'),
('p062', 'ถ่านไดสตาร์ท', 'ดัทสัน 720 โปรเฟสชั่นแนล', 100, 150, 'https://storage.googleapis.com/first_singto_bucket/senior_project/daistart.jpg', 'No data'),
('p063', 'ไส้กรองอากาศ', 'โตโยต้า ไทเกอร์ 3000cc. / 1 KZ', 200, 300, 'https://storage.googleapis.com/first_singto_bucket/senior_project/airfilter.jpg', 'No data'),
('p064', 'ไส้กรองอากาศ', 'โตโยต้า ไทเกอร์ เทอร์โบ / D4D', 260, 350, 'https://storage.googleapis.com/first_singto_bucket/senior_project/airfilter.jpg', 'No data'),
('p065', 'ไส้กรองอากาศ', 'โตโยต้า สตาร์เลท', 100, 200, 'https://storage.googleapis.com/first_singto_bucket/senior_project/airfilter.jpg', 'No data'),
('p066', 'ไส้กรองอากาศ', 'โตโยต้า โซลูน่า, AL50', 130, 200, 'https://storage.googleapis.com/first_singto_bucket/senior_project/airfilter.jpg', 'No data'),
('p067', 'ไส้กรองอากาศ', 'อีซูซุ JCM มีใบพัด', 155, 200, 'https://storage.googleapis.com/first_singto_bucket/senior_project/airfilter.jpg', 'No data'),
('p068', 'ไส้กรองอากาศ', 'อีซูซุ จัมโบ้ ร๊อกกี้ ลูกนอก', 370, 500, 'https://storage.googleapis.com/first_singto_bucket/senior_project/airfilter.jpg', 'No data'),
('p069', 'ไส้กรองอากาศ', 'ฮอนด้า CRV', 170, 250, 'https://storage.googleapis.com/first_singto_bucket/senior_project/airfilter.jpg', 'No data'),
('p070', 'ไส้กรองอากาศ', 'ฮอนด้า โอดิซซี่ 3000', 220, 300, 'https://storage.googleapis.com/first_singto_bucket/senior_project/airfilter.jpg', 'No data'),
('p071', 'ไส้กรองน้ำมันเครื่อง', 'โตโยต้า 2C', 90, 150, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p072', 'ไส้กรองน้ำมันเครื่อง', 'โตโยต้า 3L D4D', 105, 150, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p073', 'ไส้กรองน้ำมันเครื่อง', 'โตโยต้า 12R / 3K', 50, 80, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p074', 'ไส้กรองน้ำมันเครื่อง', 'มาสด้า 323', 60, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p075', 'ไส้กรองน้ำมันเครื่อง', 'มาสด้า TC M1300', 50, 80, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p076', 'ไส้กรองน้ำมันเครื่อง', 'มาสด้า ไฟท์เตอร์', 100, 150, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p077', 'ไส้กรองน้ำมันเครื่อง', 'ฮอนด้า ลูกเล็ก(ใหม่)', 60, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p078', 'ไส้กรองน้ำมันเครื่อง', 'ฮอนด้า ซีวิค อ้วนเตี้ยเก่า', 60, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p079', 'ไส้กรองน้ำมันเครื่อง', 'อีซูซุ TFR', 65, 100, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p080', 'ไส้กรองน้ำมันเครื่อง', 'อีซูซุ NPR ลูกคู่', 140, 200, 'https://storage.googleapis.com/first_singto_bucket/senior_project/oilfilter.jpg', 'No data'),
('p081', 'หัวเพลา', 'NS B11 1.5 ', 700, 1200, 'https://storage.googleapis.com/first_singto_bucket/senior_project/plao.jpg', 'No data'),
('p082', 'หัวเพลา', 'ND NX คูเป้', 700, 1200, 'https://storage.googleapis.com/first_singto_bucket/senior_project/plao.jpg', 'No data'),
('p083', 'หัวเพลา', 'ฮอนด้า CRV', 950, 1400, 'https://storage.googleapis.com/first_singto_bucket/senior_project/plao.jpg', 'No data'),
('p084', 'หัวเพลา', 'ฮอนด้า ซิตี้ 1300', 950, 1400, 'https://storage.googleapis.com/first_singto_bucket/senior_project/plao.jpg', 'No data'),
('p085', 'หัวเพลา', 'โตโยต้า MTX 4WD', 1000, 1450, 'https://storage.googleapis.com/first_singto_bucket/senior_project/plao.jpg', 'No data'),
('p086', 'หัวเพลา', 'โตโยต้า ST191 ABS', 700, 1200, 'https://storage.googleapis.com/first_singto_bucket/senior_project/plao.jpg', 'No data'),
('p087', 'ยางหุ้มแร็ค', 'โตโยต้า KE70 LH/RH', 90, 120, 'https://storage.googleapis.com/first_singto_bucket/senior_project/rack.jpg', 'No data'),
('p088', 'ยางหุ้มแร็ค', 'โตโยต้า ST150 RH', 90, 120, 'https://storage.googleapis.com/first_singto_bucket/senior_project/rack.jpg', 'No data'),
('p089', 'ยางหุ้มแร็ค', 'มาสด้า 323XG LH/RH', 90, 120, 'https://storage.googleapis.com/first_singto_bucket/senior_project/rack.jpg', 'No data'),
('p090', 'ยางหุ้มแร็ค', 'มาสด้า 626 TTL LH/RH', 90, 120, 'https://storage.googleapis.com/first_singto_bucket/senior_project/rack.jpg', 'No data'),
('p091', 'ยางหุ้มแร็ค', 'ฮอนด้า ซิตี้ LH/RH', 90, 120, 'https://storage.googleapis.com/first_singto_bucket/senior_project/rack.jpg', 'No data'),
('p092', 'ยางหุ้มแร็ค', 'ฮอนด้า CIVIC 92 LH/RH', 90, 120, 'https://storage.googleapis.com/first_singto_bucket/senior_project/rack.jpg', 'No data'),
('p093', 'กล้องยา', 'มาสด้า MAGNUM', 660, 950, 'https://storage.googleapis.com/first_singto_bucket/senior_project/klongya.jpg', 'No data'),
('p094', 'กล้องยา', 'มาสด้า B1300', 470, 650, 'https://storage.googleapis.com/first_singto_bucket/senior_project/klongya.jpg', 'No data'),
('p095', 'กล้องยา', 'โตโยต้า KE70', 450, 650, 'https://storage.googleapis.com/first_singto_bucket/senior_project/klongya.jpg', 'No data'),
('p096', 'กล้องยา', 'โตโยต้า LN 55', 500, 800, 'https://storage.googleapis.com/first_singto_bucket/senior_project/klongya.jpg', 'No data'),
('p097', 'กล้องยา', 'โตโยต้า MTX ม้าบิน', 500, 800, 'https://storage.googleapis.com/first_singto_bucket/senior_project/klongya.jpg', 'No data'),
('p098', 'กล้องยา', 'นิสสัน 720', 470, 650, 'https://storage.googleapis.com/first_singto_bucket/senior_project/klongya.jpg', 'No data'),
('p099', 'กล้องยา', 'นิสสัน BIG M', 470, 650, 'https://storage.googleapis.com/first_singto_bucket/senior_project/klongya.jpg', 'No data'),
('p100', 'กล้องยา', 'อีซูซุ TFR รุ่นใหม่, KBZ', 520, 750, 'https://storage.googleapis.com/first_singto_bucket/senior_project/klongya.jpg', 'No data');

-- --------------------------------------------------------

--
-- Table structure for table `Receipt`
--

CREATE TABLE `Receipt` (
  `Receipt_id` int NOT NULL,
  `Order_id` int NOT NULL,
  `Payment_date` datetime NOT NULL,
  `VAT` double NOT NULL,
  `Discount` double NOT NULL,
  `Grand_total` double NOT NULL,
  `receive` double NOT NULL,
  `changes` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Receipt`
--

INSERT INTO `Receipt` (`Receipt_id`, `Order_id`, `Payment_date`, `VAT`, `Discount`, `Grand_total`, `receive`, `changes`) VALUES
(1, 1, '2021-03-28 16:59:49', 1015, 0, 14500, 14500, 0),
(2, 2, '2021-03-28 18:42:37', 315, 0, 4500, 4500, 0),
(3, 3, '2021-03-28 20:49:57', 1302, 100, 18500, 18500, 0),
(4, 4, '2021-03-30 15:57:34', 301, 0, 4300, 4300, 0),
(5, 5, '2021-03-30 19:25:11', 630, 0, 9000, 9000, 0),
(6, 6, '2021-03-30 20:36:30', 2016, 800, 28000, 28000, 0),
(7, 7, '2021-03-30 20:38:46', 301, 100, 4200, 4500, 300),
(8, 8, '2021-04-03 14:24:35', 616, 0, 8800, 8800, 0),
(9, 9, '2021-04-03 15:18:51', 2506, 0, 35800, 35800, 0),
(10, 11, '2021-04-03 20:28:14', 1302, 0, 18600, 18600, 0),
(11, 12, '2021-04-03 22:31:19', 350, 0, 5000, 5000, 0),
(12, 13, '2021-04-03 23:28:39', 427, 100, 6000, 6000, 0),
(13, 14, '2021-04-04 00:44:06', 336, 0, 4800, 4800, 0);

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

CREATE TABLE `stock` (
  `stock_id` int NOT NULL,
  `Serial_Number` varchar(4) NOT NULL,
  `qty` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`stock_id`, `Serial_Number`, `qty`) VALUES
(1, 'p001', 12),
(2, 'p002', 6),
(3, 'p003', 0),
(4, 'p004', 0),
(5, 'p005', 5),
(6, 'p006', 7),
(7, 'p007', 1),
(8, 'p008', 9),
(9, 'p009', 14),
(10, 'p010', 12),
(11, 'p011', 6),
(12, 'p012', 24),
(13, 'p013', 27),
(14, 'p014', 26),
(15, 'p015', 15),
(16, 'p016', 4),
(17, 'p017', 13),
(18, 'p018', 29),
(19, 'p019', 25),
(20, 'p020', 10),
(21, 'p021', 19),
(22, 'p022', 3),
(23, 'p023', 3),
(24, 'p024', 9),
(25, 'p025', 30),
(26, 'p026', 0),
(27, 'p027', 2),
(28, 'p028', 45),
(29, 'p029', 5),
(30, 'p030', 13),
(31, 'p031', 9),
(32, 'p032', 5),
(33, 'p033', 5),
(34, 'p034', 7),
(35, 'p035', 14),
(36, 'p036', 19),
(37, 'p037', 12),
(38, 'p038', 0),
(39, 'p039', 18),
(40, 'p040', 1),
(41, 'p041', 4),
(42, 'p042', 50),
(43, 'p043', 20),
(44, 'p044', 5),
(45, 'p045', 10),
(46, 'p046', 35),
(47, 'p047', 5),
(48, 'p048', 25),
(49, 'p049', 50),
(50, 'p050', 24),
(51, 'p051', 4),
(52, 'p052', 5),
(53, 'p053', 15),
(54, 'p054', 15),
(55, 'p055', 10),
(56, 'p056', 19),
(57, 'p057', 13),
(58, 'p058', 10),
(59, 'p059', 20),
(60, 'p060', 24),
(61, 'p061', 20),
(62, 'p062', 20),
(63, 'p063', 25),
(64, 'p064', 5),
(65, 'p065', 15),
(66, 'p066', 40),
(67, 'p067', 35),
(68, 'p068', 10),
(69, 'p069', 5),
(70, 'p070', 0),
(71, 'p071', 20),
(72, 'p072', 14),
(73, 'p073', 15),
(74, 'p074', 5),
(75, 'p075', 10),
(76, 'p076', 9),
(77, 'p077', 15),
(78, 'p078', 5),
(79, 'p079', 15),
(80, 'p080', 30),
(81, 'p081', 14),
(82, 'p082', 10),
(83, 'p083', 5),
(84, 'p084', 14),
(85, 'p085', 15),
(86, 'p086', 5),
(87, 'p087', 15),
(88, 'p088', 19),
(89, 'p089', 10),
(90, 'p090', 20),
(91, 'p091', 5),
(92, 'p092', 0),
(93, 'p093', 15),
(94, 'p094', 15),
(95, 'p095', 20),
(96, 'p096', 25),
(97, 'p097', 25),
(98, 'p098', 20),
(99, 'p099', 35),
(100, 'p100', 25),
(101, 'p101', 1),
(162, 'p101', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Backorder`
--
ALTER TABLE `Backorder`
  ADD PRIMARY KEY (`backorder_id`);

--
-- Indexes for table `Claim`
--
ALTER TABLE `Claim`
  ADD PRIMARY KEY (`Claim_ID`);

--
-- Indexes for table `Claim_detail`
--
ALTER TABLE `Claim_detail`
  ADD PRIMARY KEY (`Claim_detail_id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`Customer_ID`);

--
-- Indexes for table `customer_order`
--
ALTER TABLE `customer_order`
  ADD PRIMARY KEY (`Order_Id`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`order_detail_id`),
  ADD UNIQUE KEY `order_line_id` (`order_detail_id`);

--
-- Indexes for table `product_list`
--
ALTER TABLE `product_list`
  ADD PRIMARY KEY (`Serial_Number`);
ALTER TABLE `product_list` ADD FULLTEXT KEY `pics` (`pics`);
ALTER TABLE `product_list` ADD FULLTEXT KEY `pics_2` (`pics`);

--
-- Indexes for table `Receipt`
--
ALTER TABLE `Receipt`
  ADD PRIMARY KEY (`Receipt_id`);

--
-- Indexes for table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`stock_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Backorder`
--
ALTER TABLE `Backorder`
  MODIFY `backorder_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `Claim`
--
ALTER TABLE `Claim`
  MODIFY `Claim_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `Claim_detail`
--
ALTER TABLE `Claim_detail`
  MODIFY `Claim_detail_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `customer_order`
--
ALTER TABLE `customer_order`
  MODIFY `Order_Id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `order_details`
--
ALTER TABLE `order_details`
  MODIFY `order_detail_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `Receipt`
--
ALTER TABLE `Receipt`
  MODIFY `Receipt_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `stock`
--
ALTER TABLE `stock`
  MODIFY `stock_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=163;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
