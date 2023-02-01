DROP DATABASE IF EXISTS `spk_seleksi_pegawai`;
CREATE DATABASE `spk_seleksi_pegawai`;
USE `spk_seleksi_pegawai`;

-- kriteria
CREATE TABLE `kriteria` (
	id INT PRIMARY KEY AUTO_INCREMENT,
	kriteria VARCHAR(255)NOT NULL,
	bobot DOUBLE NOT NULL
);

-- bobot_kriteria
CREATE TABLE `bobot_kriteria` (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nilai DOUBLE NOT NULl,
	klasifikasi_bobot VARCHAR(255) NOT NULL
);

-- alternatif
CREATE TABLE `alternatif` (
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255) NOT NULL,
	k1 DOUBLE NOT NULL,
	k2 DOUBLE NOT NULL,
	k3 DOUBLE NOT NULL,
	k4 DOUBLE NOT NULL
);

-- data_karyawan
CREATE TABLE `data_karyawan` (
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255) NOT NULL,
	k1 DOUBLE NOT NULL,
	k2 DOUBLE NOT NULL,
	k3 DOUBLE NOT NULL,
	k4 DOUBLE NOT NULL
);

-- insert data kriteria
INSERT INTO `kriteria` ( `kriteria`, `bobot` ) VALUES
( "Pengalaman kerja", 5),
( "Jenjang Pendidikan", 4),
( "Menguasai Office", 3),
( "Interview", 5);

-- instert data bobot_kriteria
INSERT INTO `bobot_kriteria` ( `nilai`, `klasifikasi_bobot` ) VALUES
(1, "Sangat Buruk"),
(2, "Buruk"),
(3, "Cukup baik"),
(4, "Baik"),
(5, "Sangat Baik");

-- insert data alternatif
INSERT INTO `alternatif` ( name, k1, k2, k3, k4 ) VALUES
("Anton", 2, 2, 1, 1),
("Anggi", 2, 2, 3, 3),
("Budi", 4, 3, 4, 4);

-- insert data_karyawan
INSERT INTO `data_karyawan` ( name, k1, k2, k3, k4 ) VALUES
("Anton",	2,	4,	3,	1),
("Anggi",	3,	2,	1,	3),
("Budi",	4,	3,	4,	2);

-- create view
-- view pembagi
CREATE VIEW `pembagi` AS
	SELECT 
		SQRT(SUM(POWER(k1, 2))) AS k1,
		SQRT(SUM(POWER(k2, 2))) AS k2,
		SQRT(SUM(POWER(k3, 2))) AS k3,
		SQRT(SUM(POWER(k4, 2))) AS k4
	FROM `data_karyawan`;

-- view matriks ternormalisai
CREATE VIEW `matriks_ternormalisai` AS
	SELECT
		name,
		(k1 / (SELECT k1 FROM `pembagi`)) as k1
	FROM `data_karyawan`;