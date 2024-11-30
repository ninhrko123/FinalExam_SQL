DROP DATABASE IF EXISTS ThucTap1;
CREATE DATABASE ThucTap1;
USE ThucTap1;
-- GiangVien(magv, hoten, luong)
DROP TABLE IF EXISTS  GiangVien;
CREATE TABLE GiangVien(
magv SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
hoten VARCHAR(30) NOT NULL,
luong INT NOT NULL

);
-- SinhVien(masv, hoten, namsinh, quequan)
DROP TABLE IF EXISTS SinhVien;
CREATE TABLE SinhVien(
masv SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
hoten VARCHAR(30) NOT NULL,
namsinh DATETIME NOT NULL,
quequan VARCHAR(30) NOT NULL
);
-- DeTai(madt, tendt, kinhphi, NoiThucTap)
DROP TABLE IF EXISTS DeTai;
CREATE TABLE DeTai(
madt SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
tendt VARCHAR(30) NOT NULL,
kinhphi INT NOT NULL,
NoiThucTap VARCHAR(30) NOT NULL
);

-- HuongDan(id, masv, madt, magv, ketqua)
DROP TABLE IF EXISTS HuongDan;
CREATE TABLE HuongDan(
id  SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
madt SMALLINT UNSIGNED NOT NULL,
masv SMALLINT UNSIGNED NOT NULL,
magv SMALLINT UNSIGNED NOT NULL,
ketqua TINYINT UNSIGNED NOT NULL,
CONSTRAINT FK_Huongdan_GiangVien FOREIGN KEY (magv) REFERENCES `GiangVien`(magv),
CONSTRAINT FK_Huongdan_SinhVien FOREIGN KEY (masv) REFERENCES `SinhVien`(masv),
CONSTRAINT FK_Huongdan_DeTai FOREIGN KEY (madt) REFERENCES `DeTai`(madt)
);




-- insert dữ liệu 
SELECT * FROM ThucTap1.GiangVien;
INSERT INTO ThucTap1.GiangVien(`hoten`,`luong`)
VALUES    					('Nguyễn Đàm' ,'5000000'),
							('Nguyễn Đạo', '4000000'),
                            ('Nguyễn Linh', '4560000'),
                            ('Vũ Trang',  '7000000');
                            

                            
SELECT * FROM ThucTap1.SinhVien ;
INSERT INTO ThucTap1.SinhVien     ( `hoten`,				`namsinh`,				`quequan`)
VALUES    						 ('SinhVien 1',		 '1998-11-11 00:00:00',		 'ND'),
								 ('SinhVien 2',		 '1999-02-22 00:00:00',		 'HN'),
                                 ('SinhVien 3',		 '1997-01-01 00:00:00',		 'QN'),
                                 ('SinhVien 4',		 '1999-01-12 00:00:00',		 'TH'),
                                 ('SinhVien 5',		 '1998-03-30 00:00:00',		 'BG');

select * from DeTai;

INSERT INTO ThucTap1.DeTai    ( `tendt`,				`kinhphi`,				`NoiThucTap`)
VALUES    					 ('DeTai 1' , ' 3000000', 'FPT'	),
							  ('DeTai 2', '5096600','VIETTEL'	),
                              ('DeTai 3'	, '2640250','VINAPHONE'),
                              ('CONG NGHE SINH HOC'	, '2630000','MOBIPHONE');
                            
 SELECT * FROM HuongDan;        
 INSERT INTO `ThucTap1`.`huongdan` (`madt`,		 `masv`, 	`magv`, 		`ketqua`	)
 VALUES							 (	'1', 			'4', 			'3', 	 '7'	),
								 (	'2', 			'1', 			'4', 	 '8 '	),
                                 (	'3', 			'2', 			'1', 	 '9'	),
                                 (	'4', 			'1', 			'3', 	 '10'	);
                              
 
 -- 2. Viết lệnh để
-- a) Lấy tất cả các sinh viên chưa có đề tài hướng dẫn
-- b) Lấy ra số sinh viên làm đề tài ‘CONG NGHE SINH HOC’
                            
-- A)
SELECT s.masv, s.hoten  FROM sinhVien AS s
LEFT JOIN HuongDan AS h ON s.masv = h.masv
WHERE h.masv IS NULL;


-- B)
SELECT COUNT(*)  AS `SLSV LÀM CONG NGHE SINH HOC`
FROM huongdan
where madt = (
	select madt 
    from DeTai
    where tendt = 'CONG NGHE SINH HOC'
);

SELECT COUNT(*)  AS `SLSV LÀM CONG NGHE SINH HOC`FROM huongdan h
INNER JOIN detai d ON h.madt =d.madt
WHERE tendt = 'CONG NGHE SINH HOC';


-- C ) 3. Tạo view có tên là "SinhVienInfo" lấy các thông tin về học sinh bao gồm:
-- mã số, họ tên và tên đề tài
-- (Nếu sinh viên chưa có đề tài thì column tên đề tài sẽ in ra "Chưa có")

CREATE OR REPLACE VIEW vw_SinhVienInfo AS
SELECT  s.masv, s.`hoten`, ifnull(d.`tendt`, 'Chưa có')
FROM huongdan h
LEFT JOIN sinhvien s ON s.masv = h.masv
LEFT JOIN detai d ON d.madt = h.madt;

update huongdan set masv =  10 where madt = 1;


CREATE OR REPLACE VIEW vw_SinhVienInfo AS
SELECT s.masv, s.`hoten`,d.`tendt` 
FROM huongdan h
INNER JOIN sinhvien s ON s.masv = h.masv
INNER JOIN detai d ON d.madt = h.madt
UNION ALL 
SELECT s.masv, s.`hoten`,'Chưa có' 
FROM SinhVien s
LEFT JOIN huongdan h ON s.masv = h.masv
WHERE h.madt IS NULL;

-- TEST XEM VIEW vw_SinhVienInfo
SELECT * FROM vw_SinhVienInfo;

-- 4. Tạo trigger cho table SinhVien khi insert sinh viên có năm sinh <= 1900 thì hiện ra thông báo "năm sinh phải > 1900"
DROP TRIGGER IF EXISTS trg_bfInsertOnSv;

DELIMITER $$
	CREATE TRIGGER trg_bfInsertOnSv
    BEFORE INSERT ON sinhvien
    FOR EACH ROW
    BEGIN		
        IF NEW.namsinh <'1900-01-01'  THEN
			SIGNAL SQLSTATE '12345'
			SET MESSAGE_TEXT = 'năm sinh phải > 1900';
		END IF;
    END$$
DELIMITER ;

select * from ThucTap1.SinhVien;

INSERT INTO ThucTap1.SinhVien     ( `hoten`,				`namsinh`,				`quequan`)
VALUES    						 ('SinhVien 6',		 '1998-11-11 00:00:00',		 'ND'),
								 ('SinhVien 7',		 '1800-02-22 00:00:00',		 'HN'),
                                 ('SinhVien 8',		 '1997-01-01 00:00:00',		 'QN'),
                                 ('SinhVien 9',		 '1999-01-12 00:00:00',		 'TH');



-- Câu 5
-- 5. Hãy cấu hình table sao cho khi xóa 1 sinh viên nào đó thì sẽ tất cả thông
-- tin trong table HuongDan liên quan tới sinh viên đó sẽ bị xóa đi

DELIMITER $$
DROP TRIGGER IF EXISTS before_delete_sinhvien;
CREATE TRIGGER before_delete_sinhvien
BEFORE DELETE ON SinhVien
FOR EACH ROW
BEGIN
    DELETE FROM HuongDan WHERE masv = OLD.masv;
END$$
DELIMITER ;

DELETE FROM SinhVien WHERE masv = 1;


-- Xóa FK 
 ALTER TABLE huongdan DROP FOREIGN KEY FK_Huongdan_Sinhvien;
 --  Thêm FK
  ALTER TABLE huongdan ADD CONSTRAINT FK_Huongdan_Sinhvien FOREIGN KEY (masv) REFERENCES `SinhVien`(masv) ON DELETE CASCADE;
  -- Test
  DELETE FROM sinhvien  WHERE masv = 4;