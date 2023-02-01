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
CREATE VIEW `matriks_ternormalisasi` AS
	SELECT
		name,
		(k1 / (SELECT k1 FROM `pembagi`)) as k1,
		(k2 / (SELECT k2 FROM `pembagi`)) as k2,
		(k3 / (SELECT k3 FROM `pembagi`)) as k3,
		(k4 / (SELECT k4 FROM `pembagi`)) as k4
	FROM `data_karyawan`;

-- view normalisasi terbobot
CREATE VIEW `normalisasi_terbobot` AS
	SELECT
		name,
		(k1 * (SELECT `bobot` FROM `kriteria` WHERE `kriteria`.`kriteria` = "Pengalaman kerja" )) as k1,
		(k2 * (SELECT `bobot` FROM `kriteria` WHERE `kriteria`.`kriteria` = "Jenjang Pendidikan" )) as k2,
		(k3 * (SELECT `bobot` FROM `kriteria` WHERE `kriteria`.`kriteria` = "Menguasai Office" )) as k3,
		(k4 * (SELECT `bobot` FROM `kriteria` WHERE `kriteria`.`kriteria` = "Interview" )) as k4
	FROM `matriks_ternormalisasi`;

-- view max min (solusi positif dan negatif)
CREATE VIEW `max_min` AS
	SELECT
		MAX(k1) AS k1,
		MAX(k2) AS k2,
		MAX(k3) AS k3,
		MAX(k4) AS k4
	FROM `normalisasi_terbobot`
	UNION
	SELECT
		MIN(k1),
		MIN(k2),
		MIN(k3),
		MIN(k4)
	FROM `normalisasi_terbobot`;
-- show this view
SELECT CONCAT("max  | ", k1) as "name | k1", k2, k3, k4 FROM `max_min`;

-- view jarak solusi ideal positif negatif
CREATE VIEW `jarak_solusi_ideal_positif_negatif` AS
	SELECT DISTINCT
		`normalisasi_terbobot`.`name`,
		SQRT(
			-- (($C$53-C46)^2)
			POWER(((SELECT MAX(k1) FROM `max_min`) - (SELECT k1 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anton")), 2) +
			-- (($D$53-D46)^2)
			POWER(((SELECT MAX(k2) FROM `max_min`) - (SELECT k2 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anton")), 2) +
			-- (($E$53-E46)^2)
			POWER(((SELECT MAX(k3) FROM `max_min`) - (SELECT k3 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anton")), 2) +
			-- (($F$53-F46)^2)
			POWER(((SELECT MAX(k4) FROM `max_min`) - (SELECT k4 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anton")), 2))
		AS positif,
		SQRT(
			-- ((C46-$C$54)^2)
			POWER(((SELECT MIN(k1) FROM `max_min`) - (SELECT k1 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anton")), 2) +
			-- ((D46-$D$54)^2)
			POWER(((SELECT MIN(k2) FROM `max_min`) - (SELECT k2 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anton")), 2) +
			-- ((E46-$E$54)^2)
			POWER(((SELECT MIN(k3) FROM `max_min`) - (SELECT k3 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anton")), 2) +
			-- ((F46-$F$54)^2)
			POWER(((SELECT MIN(k4) FROM `max_min`) - (SELECT k4 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anton")), 2))
		AS negatif
	FROM `max_min`, `normalisasi_terbobot` WHERE `normalisasi_terbobot`.`name` = "Anton"
	UNION
	SELECT DISTINCT
		`normalisasi_terbobot`.`name`,
		SQRT(
			-- (($C$53-C46)^2)
			POWER(((SELECT MAX(k1) FROM `max_min`) - (SELECT k1 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anggi")), 2) +
			-- (($D$53-D46)^2)
			POWER(((SELECT MAX(k2) FROM `max_min`) - (SELECT k2 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anggi")), 2) +
			-- (($E$53-E46)^2)
			POWER(((SELECT MAX(k3) FROM `max_min`) - (SELECT k3 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anggi")), 2) +
			-- (($F$53-F46)^2)
			POWER(((SELECT MAX(k4) FROM `max_min`) - (SELECT k4 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anggi")), 2)),
		SQRT(
			-- ((C46-$C$54)^2)
			POWER(((SELECT MIN(k1) FROM `max_min`) - (SELECT k1 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anggi")), 2) +
			-- ((D46-$D$54)^2)
			POWER(((SELECT MIN(k2) FROM `max_min`) - (SELECT k2 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anggi")), 2) +
			-- ((E46-$E$54)^2)
			POWER(((SELECT MIN(k3) FROM `max_min`) - (SELECT k3 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anggi")), 2) +
			-- ((F46-$F$54)^2)
			POWER(((SELECT MIN(k4) FROM `max_min`) - (SELECT k4 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Anggi")), 2))
	FROM `max_min`, `normalisasi_terbobot`  WHERE `normalisasi_terbobot`.`name` = "Anggi"
	UNION
	SELECT DISTINCT
		`normalisasi_terbobot`.`name`,
		SQRT(
			-- (($C$53-C46)^2)
			POWER(((SELECT MAX(k1) FROM `max_min`) - (SELECT k1 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Budi")), 2) +
			-- (($D$53-D46)^2)
			POWER(((SELECT MAX(k2) FROM `max_min`) - (SELECT k2 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Budi")), 2) +
			-- (($E$53-E46)^2)
			POWER(((SELECT MAX(k3) FROM `max_min`) - (SELECT k3 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Budi")), 2) +
			-- (($F$53-F46)^2)
			POWER(((SELECT MAX(k4) FROM `max_min`) - (SELECT k4 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Budi")), 2)),
		SQRT(
			-- ((C46-$C$54)^2)
			POWER(((SELECT MIN(k1) FROM `max_min`) - (SELECT k1 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Budi")), 2) +
			-- ((D46-$D$54)^2)
			POWER(((SELECT MIN(k2) FROM `max_min`) - (SELECT k2 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Budi")), 2) +
			-- ((E46-$E$54)^2)
			POWER(((SELECT MIN(k3) FROM `max_min`) - (SELECT k3 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Budi")), 2) +
			-- ((F46-$F$54)^2)
			POWER(((SELECT MIN(k4) FROM `max_min`) - (SELECT k4 FROM `normalisasi_terbobot` AS `nb` WHERE `nb`.`name` = "Budi")), 2))
	FROM `max_min`, `normalisasi_terbobot`  WHERE `normalisasi_terbobot`.`name` = "Budi"
	GROUP BY `normalisasi_terbobot`.`name`;
