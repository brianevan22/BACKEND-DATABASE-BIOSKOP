-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 31 Okt 2025 pada 10.30
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bioskop`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `customer`
--

INSERT INTO `customer` (`customer_id`, `nama`, `email`, `no_hp`) VALUES
(1, 'Fajar Hidayat', 'fajar.hidayat@gmail.com', '081234567895'),
(2, 'Gita Permata', 'gita.permata@gmail.com', '081234567896'),
(3, 'Hendra Saputra', 'hendra.saputra@gmail.com', '081234567897'),
(4, 'Indah Maharani', 'indah.maharani@gmail.com', '081234567898'),
(5, 'Joko Purnomo', 'joko.purnomo@gmail.com', '081234567899');

-- --------------------------------------------------------

--
-- Struktur dari tabel `detail_transaksi`
--

CREATE TABLE `detail_transaksi` (
  `detail_id` int(11) NOT NULL,
  `transaksi_id` int(11) DEFAULT NULL,
  `tiket_id` int(11) DEFAULT NULL,
  `film_id` int(11) NOT NULL,
  `harga` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `detail_transaksi`
--

INSERT INTO `detail_transaksi` (`detail_id`, `transaksi_id`, `tiket_id`, `film_id`, `harga`) VALUES
(114, 54, 258, 2, 100000.00),
(115, 54, 259, 2, 100000.00),
(116, 54, 260, 2, 100000.00),
(117, 54, 261, 2, 100000.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `film`
--

CREATE TABLE `film` (
  `film_id` int(11) NOT NULL,
  `judul` varchar(200) NOT NULL,
  `durasi` int(11) NOT NULL,
  `sinopsis` text DEFAULT NULL,
  `genre_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `film`
--

INSERT INTO `film` (`film_id`, `judul`, `durasi`, `sinopsis`, `genre_id`) VALUES
(1, 'Avengers: Endgame', 181, 'Pertarungan terakhir melawan Thanos demi menyelamatkan alam semesta.', 1),
(2, 'Laskar Pelangi', 120, 'Kisah anak-anak di Belitung yang penuh semangat meraih mimpi.', 2),
(3, 'My Stupid Boss', 110, 'Komedian karyawan yang menghadapi bos eksentrik.', 3),
(4, 'Pengabdi Setan', 107, 'Keluarga diteror makhluk gaib setelah kematian ibu.', 4),
(5, 'Toy Story 4', 100, 'Petualangan Woody, Buzz dan mainan lainnya menemukan arti keluarga.', 5);

-- --------------------------------------------------------

--
-- Struktur dari tabel `genre`
--

CREATE TABLE `genre` (
  `genre_id` int(11) NOT NULL,
  `nama_genre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `genre`
--

INSERT INTO `genre` (`genre_id`, `nama_genre`) VALUES
(1, 'Action'),
(2, 'Drama'),
(3, 'Komedi'),
(4, 'Horror'),
(5, 'Animation');

-- --------------------------------------------------------

--
-- Struktur dari tabel `jadwal`
--

CREATE TABLE `jadwal` (
  `jadwal_id` int(11) NOT NULL,
  `film_id` int(11) DEFAULT NULL,
  `studio_id` int(11) DEFAULT NULL,
  `tanggal` date NOT NULL,
  `jam_mulai` time NOT NULL,
  `jam_selesai` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `jadwal`
--

INSERT INTO `jadwal` (`jadwal_id`, `film_id`, `studio_id`, `tanggal`, `jam_mulai`, `jam_selesai`) VALUES
(2, 3, 1, '2025-11-27', '12:00:00', '13:50:00'),
(3, 5, 2, '2025-10-23', '15:00:00', '16:40:00'),
(13, 1, 3, '2025-11-20', '15:10:00', '17:10:00'),
(14, 4, 2, '2025-11-19', '18:10:00', '20:10:00'),
(16, 2, 2, '2025-11-04', '16:00:00', '19:00:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kasir`
--

CREATE TABLE `kasir` (
  `kasir_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `shift` enum('pagi','siang','malam') NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kasir`
--

INSERT INTO `kasir` (`kasir_id`, `nama`, `shift`, `no_hp`) VALUES
(1, 'Rina Oktaviani', 'pagi', '081222334455'),
(2, 'Slamet Wijaya', 'siang', '082233445566'),
(3, 'Wulan Anggraini', 'malam', '083344556677');

-- --------------------------------------------------------

--
-- Struktur dari tabel `komentar`
--

CREATE TABLE `komentar` (
  `komentar_id` int(11) NOT NULL,
  `users_id` int(11) NOT NULL,
  `film_id` int(11) DEFAULT NULL,
  `isi_komentar` text NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `tanggal` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `komentar`
--

INSERT INTO `komentar` (`komentar_id`, `users_id`, `film_id`, `isi_komentar`, `rating`, `tanggal`) VALUES
(1, 1, 2, 'Filmnya sangat inspiratif dan juga memotivasi untuk tetap semangat belajar', 5, '2025-09-27'),
(2, 2, 3, 'Ceritanya lucu banget dan juga alurnya tidak membosankan', 5, '2025-09-27'),
(3, 5, 4, 'Vibes seremnya dapet banget dan juga alur ceritanya yang gak seperti film horror pada umumnya', 4, '2025-09-27');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kursi`
--

CREATE TABLE `kursi` (
  `kursi_id` int(11) NOT NULL,
  `nomor_kursi` varchar(10) NOT NULL,
  `studio_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kursi`
--

INSERT INTO `kursi` (`kursi_id`, `nomor_kursi`, `studio_id`) VALUES
(1, 'A1', 1),
(10, 'A10', 1),
(97, 'A11', 1),
(98, 'A12', 1),
(99, 'A13', 1),
(100, 'A14', 1),
(101, 'A15', 1),
(2, 'A2', 1),
(3, 'A3', 1),
(4, 'A4', 1),
(5, 'A5', 1),
(6, 'A6', 1),
(7, 'A7', 1),
(8, 'A8', 1),
(9, 'A9', 1),
(11, 'B1', 2),
(82, 'B10', 2),
(83, 'B11', 2),
(84, 'B12', 2),
(85, 'B13', 2),
(86, 'B14', 2),
(87, 'B15', 2),
(12, 'B2', 2),
(13, 'B3', 2),
(14, 'B4', 2),
(15, 'B5', 2),
(78, 'B6', 2),
(79, 'B7', 2),
(80, 'B8', 2),
(81, 'B9', 2),
(16, 'C1', 3),
(91, 'C10', 3),
(92, 'C11', 3),
(93, 'C12', 3),
(94, 'C13', 3),
(95, 'C14', 3),
(96, 'C15', 3),
(17, 'C2', 3),
(18, 'C3', 3),
(19, 'C4', 3),
(20, 'C5', 3),
(76, 'C6', 3),
(88, 'C7', 3),
(89, 'C8', 3),
(90, 'C9', 3);

-- --------------------------------------------------------

--
-- Struktur dari tabel `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('1njRdAvftlIAZuEWEKGiiV2uW7flqY11F8yeMvAA', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic0t2RExXS0FzNFh3ZkFzM0dKaEdwOE0wTjFXV1hPc0pvN01UREZCbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1761820662);

-- --------------------------------------------------------

--
-- Struktur dari tabel `studio`
--

CREATE TABLE `studio` (
  `studio_id` int(11) NOT NULL,
  `nama_studio` varchar(50) NOT NULL,
  `tipe_studio` varchar(50) NOT NULL,
  `kapasitas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `studio`
--

INSERT INTO `studio` (`studio_id`, `nama_studio`, `tipe_studio`, `kapasitas`) VALUES
(1, 'Studio 1', 'Regular', 15),
(2, 'Studio 2', 'IMAX', 15),
(3, 'Studio 3', '3D', 15);

-- --------------------------------------------------------

--
-- Struktur dari tabel `tiket`
--

CREATE TABLE `tiket` (
  `tiket_id` int(11) NOT NULL,
  `jadwal_id` int(11) DEFAULT NULL,
  `kursi_id` int(11) DEFAULT NULL,
  `harga` decimal(10,2) NOT NULL,
  `status` enum('tersedia','terjual') DEFAULT 'tersedia'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tiket`
--

INSERT INTO `tiket` (`tiket_id`, `jadwal_id`, `kursi_id`, `harga`, `status`) VALUES
(11, 2, 1, 50000.00, 'tersedia'),
(12, 2, 2, 50000.00, 'tersedia'),
(13, 2, 3, 50000.00, 'tersedia'),
(14, 2, 4, 50000.00, 'tersedia'),
(15, 2, 5, 50000.00, 'tersedia'),
(16, 2, 6, 50000.00, 'tersedia'),
(17, 2, 7, 50000.00, 'tersedia'),
(18, 2, 8, 50000.00, 'tersedia'),
(19, 2, 9, 50000.00, 'tersedia'),
(20, 2, 10, 50000.00, 'tersedia'),
(21, 3, 11, 100000.00, 'tersedia'),
(22, 3, 12, 100000.00, 'tersedia'),
(23, 3, 13, 100000.00, 'tersedia'),
(24, 3, 14, 100000.00, 'tersedia'),
(25, 3, 15, 100000.00, 'tersedia'),
(169, 3, 78, 100000.00, 'tersedia'),
(170, 3, 79, 100000.00, 'tersedia'),
(171, 3, 80, 100000.00, 'tersedia'),
(172, 3, 81, 100000.00, 'tersedia'),
(173, 3, 82, 100000.00, 'tersedia'),
(174, 3, 83, 100000.00, 'tersedia'),
(175, 3, 84, 100000.00, 'tersedia'),
(176, 3, 85, 100000.00, 'tersedia'),
(177, 3, 86, 100000.00, 'tersedia'),
(178, 3, 87, 100000.00, 'tersedia'),
(193, 2, 97, 50000.00, 'tersedia'),
(194, 2, 98, 50000.00, 'tersedia'),
(195, 2, 99, 50000.00, 'tersedia'),
(196, 2, 100, 50000.00, 'tersedia'),
(197, 2, 101, 50000.00, 'tersedia'),
(228, 13, 16, 75000.00, 'tersedia'),
(229, 13, 17, 75000.00, 'tersedia'),
(230, 13, 18, 75000.00, 'tersedia'),
(231, 13, 19, 75000.00, 'tersedia'),
(232, 13, 20, 75000.00, 'tersedia'),
(233, 13, 76, 75000.00, 'tersedia'),
(234, 13, 88, 75000.00, 'tersedia'),
(235, 13, 89, 75000.00, 'tersedia'),
(236, 13, 90, 75000.00, 'tersedia'),
(237, 13, 91, 75000.00, 'tersedia'),
(238, 13, 92, 75000.00, 'tersedia'),
(239, 13, 93, 75000.00, 'tersedia'),
(240, 13, 94, 75000.00, 'tersedia'),
(241, 13, 95, 75000.00, 'tersedia'),
(242, 13, 96, 75000.00, 'tersedia'),
(243, 14, 11, 100000.00, 'tersedia'),
(244, 14, 12, 100000.00, 'tersedia'),
(245, 14, 13, 100000.00, 'tersedia'),
(246, 14, 14, 100000.00, 'tersedia'),
(247, 14, 15, 100000.00, 'tersedia'),
(248, 14, 78, 100000.00, 'tersedia'),
(249, 14, 79, 100000.00, 'tersedia'),
(250, 14, 80, 100000.00, 'tersedia'),
(251, 14, 81, 100000.00, 'tersedia'),
(252, 14, 82, 100000.00, 'tersedia'),
(253, 14, 83, 100000.00, 'tersedia'),
(254, 14, 84, 100000.00, 'tersedia'),
(255, 14, 85, 100000.00, 'tersedia'),
(256, 14, 86, 100000.00, 'tersedia'),
(257, 14, 87, 100000.00, 'tersedia'),
(258, 16, 11, 100000.00, 'terjual'),
(259, 16, 12, 100000.00, 'terjual'),
(260, 16, 13, 100000.00, 'terjual'),
(261, 16, 14, 100000.00, 'terjual'),
(262, 16, 15, 100000.00, 'tersedia'),
(263, 16, 78, 100000.00, 'tersedia'),
(264, 16, 79, 100000.00, 'tersedia'),
(265, 16, 80, 100000.00, 'tersedia'),
(266, 16, 81, 100000.00, 'tersedia'),
(267, 16, 82, 100000.00, 'tersedia'),
(268, 16, 83, 100000.00, 'tersedia'),
(269, 16, 84, 100000.00, 'tersedia'),
(270, 16, 85, 100000.00, 'tersedia'),
(271, 16, 86, 100000.00, 'tersedia'),
(272, 16, 87, 100000.00, 'tersedia');

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaksi`
--

CREATE TABLE `transaksi` (
  `transaksi_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `kasir_id` int(11) DEFAULT NULL,
  `tanggal_transaksi` date DEFAULT NULL,
  `total_harga` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `transaksi`
--

INSERT INTO `transaksi` (`transaksi_id`, `customer_id`, `kasir_id`, `tanggal_transaksi`, `total_harga`) VALUES
(29, 1, NULL, '2025-10-30', 1300000.00),
(30, 1, NULL, '2025-10-30', 975000.00),
(31, 1, NULL, '2025-10-30', 650000.00),
(32, 1, NULL, '2025-10-30', 650000.00),
(34, 1, NULL, '2025-10-31', 150000.00),
(52, 1, NULL, '2025-10-31', 75000.00),
(53, 1, NULL, '2025-10-31', 100000.00),
(54, 1, NULL, '2025-10-31', 400000.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','customer') NOT NULL DEFAULT 'customer',
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `api_token` varchar(80) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `role`, `name`, `email`, `api_token`, `created_at`, `updated_at`) VALUES
(1, 'brian', '$2y$12$Ha8QOLT0WI09ku./jFXGB.CWXQ0boBUxu/bREtnRDvc5tvsSuwEWi', 'customer', 'brian', NULL, 'k7Ebx2HBUM8BGASHuXnHosuCPiLFh4fzFmIyaC3r', '2025-10-30 10:00:08', '2025-10-31 01:33:44'),
(2, 'bran', '$2y$12$cPEGSx.2jCg8XsXlnzwF8.tNvT.ONEVMnoluCX2LokcIPSM0Kv5s6', 'customer', 'bran', NULL, '16blSId8HgBC6myqCDj0MPJ9mJeZQlIEEZKcb19E', '2025-10-30 16:08:24', '2025-10-30 20:05:32'),
(3, 'yanto', '$2y$12$TxKwwrPONbp4cCoKuT5S8uuU.nBGDd/TQ6L064PoAxQksObXdqhyq', 'customer', 'yanto', NULL, 'jHEp3pOXslbl9BFSfTCyzjjXNmxrPA1ys6HNM2xH', '2025-10-31 01:54:42', '2025-10-31 01:55:34'),
(4, 'admin', '$2y$12$8i1Cdm42Hcps225y7sY9Vub0kGugHgdGXNqBJ38qRAjPR9U1FVLtO', 'admin', 'Administrator', 'admin@bioskop.local', 'admin-token-123', '2025-10-31 02:00:00', '2025-10-31 02:00:00');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indeks untuk tabel `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indeks untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indeks untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD PRIMARY KEY (`detail_id`),
  ADD UNIQUE KEY `transaksi_id` (`transaksi_id`,`tiket_id`),
  ADD KEY `fk_detail_tiket` (`tiket_id`),
  ADD KEY `film_id` (`film_id`);

--
-- Indeks untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indeks untuk tabel `film`
--
ALTER TABLE `film`
  ADD PRIMARY KEY (`film_id`),
  ADD KEY `fk_film_genre` (`genre_id`);

--
-- Indeks untuk tabel `genre`
--
ALTER TABLE `genre`
  ADD PRIMARY KEY (`genre_id`);

--
-- Indeks untuk tabel `jadwal`
--
ALTER TABLE `jadwal`
  ADD PRIMARY KEY (`jadwal_id`),
  ADD KEY `fk_jadwal_film` (`film_id`),
  ADD KEY `fk_jadwal_studio` (`studio_id`);

--
-- Indeks untuk tabel `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indeks untuk tabel `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `kasir`
--
ALTER TABLE `kasir`
  ADD PRIMARY KEY (`kasir_id`);

--
-- Indeks untuk tabel `komentar`
--
ALTER TABLE `komentar`
  ADD PRIMARY KEY (`komentar_id`),
  ADD KEY `fk_komentar_customer` (`users_id`),
  ADD KEY `fk_komentar_film` (`film_id`);

--
-- Indeks untuk tabel `kursi`
--
ALTER TABLE `kursi`
  ADD PRIMARY KEY (`kursi_id`),
  ADD UNIQUE KEY `nomor_kursi` (`nomor_kursi`,`studio_id`),
  ADD KEY `fk_kursi_studio` (`studio_id`);

--
-- Indeks untuk tabel `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indeks untuk tabel `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indeks untuk tabel `studio`
--
ALTER TABLE `studio`
  ADD PRIMARY KEY (`studio_id`);

--
-- Indeks untuk tabel `tiket`
--
ALTER TABLE `tiket`
  ADD PRIMARY KEY (`tiket_id`),
  ADD UNIQUE KEY `jadwal_id` (`jadwal_id`,`kursi_id`),
  ADD KEY `fk_tiket_kursi` (`kursi_id`);

--
-- Indeks untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`transaksi_id`),
  ADD KEY `fk_transaksi_customer` (`customer_id`),
  ADD KEY `fk_transaksi_kasir` (`kasir_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `api_token` (`api_token`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  MODIFY `detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `film`
--
ALTER TABLE `film`
  MODIFY `film_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `genre`
--
ALTER TABLE `genre`
  MODIFY `genre_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `jadwal`
--
ALTER TABLE `jadwal`
  MODIFY `jadwal_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT untuk tabel `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kasir`
--
ALTER TABLE `kasir`
  MODIFY `kasir_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `komentar`
--
ALTER TABLE `komentar`
  MODIFY `komentar_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `kursi`
--
ALTER TABLE `kursi`
  MODIFY `kursi_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- AUTO_INCREMENT untuk tabel `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `studio`
--
ALTER TABLE `studio`
  MODIFY `studio_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `tiket`
--
ALTER TABLE `tiket`
  MODIFY `tiket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=273;

--
-- AUTO_INCREMENT untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `transaksi_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD CONSTRAINT `detail_transaksi_ibfk_1` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`),
  ADD CONSTRAINT `fk_detail_tiket` FOREIGN KEY (`tiket_id`) REFERENCES `tiket` (`tiket_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_detail_transaksi` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi` (`transaksi_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `film`
--
ALTER TABLE `film`
  ADD CONSTRAINT `fk_film_genre` FOREIGN KEY (`genre_id`) REFERENCES `genre` (`genre_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `jadwal`
--
ALTER TABLE `jadwal`
  ADD CONSTRAINT `fk_jadwal_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_jadwal_studio` FOREIGN KEY (`studio_id`) REFERENCES `studio` (`studio_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `komentar`
--
ALTER TABLE `komentar`
  ADD CONSTRAINT `fk_komentar_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `kursi`
--
ALTER TABLE `kursi`
  ADD CONSTRAINT `fk_kursi_studio` FOREIGN KEY (`studio_id`) REFERENCES `studio` (`studio_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tiket`
--
ALTER TABLE `tiket`
  ADD CONSTRAINT `fk_tiket_jadwal` FOREIGN KEY (`jadwal_id`) REFERENCES `jadwal` (`jadwal_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_tiket_kursi` FOREIGN KEY (`kursi_id`) REFERENCES `kursi` (`kursi_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `fk_transaksi_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transaksi_kasir` FOREIGN KEY (`kasir_id`) REFERENCES `kasir` (`kasir_id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
