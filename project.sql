/******************************************************************
* Skills: Stored Procedures, Functions, Triggers, Transactions
******************************************************************/
USE QLDIEM;

DELIMITER $$

/* 1. Procedure: Thống kê số lượng SV của một khoa */
DROP PROCEDURE IF EXISTS sp_Khoa_ThongKe$$
CREATE PROCEDURE sp_Khoa_ThongKe(IN p_MaKhoa VARCHAR(10))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM KHOA WHERE MaKhoa = p_MaKhoa) THEN
    SELECT CONCAT('Không có khoa: ', p_MaKhoa) AS ThongBao;
  ELSE
    SELECT k.MaKhoa, k.TenKhoa, COUNT(s.MSSV) AS SoSV
    FROM KHOA k
    LEFT JOIN SINHVIEN s ON s.MaKhoa = k.MaKhoa
    WHERE k.MaKhoa = p_MaKhoa
    GROUP BY k.MaKhoa, k.TenKhoa;
  END IF;
END$$

/* 2. Procedure: Liệt kê SV có điểm < giá trị cho trước */
DROP PROCEDURE IF EXISTS sp_SV_DiemNhoHon$$
CREATE PROCEDURE sp_SV_DiemNhoHon(IN p_Diem FLOAT)
BEGIN
  IF NOT EXISTS (SELECT 1 FROM KETQUA WHERE Diem < p_Diem) THEN
    SELECT CONCAT('Không có sinh viên có điểm < ', p_Diem) AS ThongBao;
  ELSE
    SELECT k.MSSV, s.HoTen, k.MaHP, k.Diem
    FROM KETQUA k
    JOIN SINHVIEN s ON s.MSSV = k.MSSV
    WHERE k.Diem < p_Diem;
  END IF;
END$$

/* 3. Procedure: Tính điểm trung bình của SV */
DROP PROCEDURE IF EXISTS sp_DIEM_TB$$
CREATE PROCEDURE sp_DIEM_TB(IN p_MSSV VARCHAR(10), OUT p_DiemTB FLOAT)
BEGIN
  IF NOT EXISTS (SELECT 1 FROM SINHVIEN WHERE MSSV = p_MSSV) THEN
    SET p_DiemTB = -1;
  ELSE
    SELECT IFNULL(SUM(Diem * SoTinChi)/SUM(SoTinChi), 0)
      INTO p_DiemTB
    FROM KETQUA
    WHERE MSSV = p_MSSV;
  END IF;
END$$

/* 4. Procedure: Bảng điểm trung bình của SV trong một khoa */
DROP PROCEDURE IF EXISTS sp_BangDiem_TB$$
CREATE PROCEDURE sp_BangDiem_TB(IN p_MaKhoa VARCHAR(10))
BEGIN
  SELECT s.MSSV, s.HoTen,
         IFNULL(SUM(kq.Diem * kq.SoTinChi)/SUM(kq.SoTinChi), 0) AS DiemTB
  FROM SINHVIEN s
  LEFT JOIN KETQUA kq ON s.MSSV = kq.MSSV
  WHERE s.MaKhoa = p_MaKhoa
  GROUP BY s.MSSV, s.HoTen;
END$$

/* 5. Procedure: Liệt kê SV chưa học một học phần */
DROP PROCEDURE IF EXISTS sp_SV_ChuaHoc_MaHP$$
CREATE PROCEDURE sp_SV_ChuaHoc_MaHP(IN p_MaHP VARCHAR(20))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM HOCPHAN WHERE MaHP = p_MaHP) THEN
    SELECT CONCAT('Không có học phần: ', p_MaHP) AS ThongBao;
  ELSE
    SELECT s.MSSV, s.HoTen
    FROM SINHVIEN s
    WHERE s.MSSV NOT IN (
      SELECT MSSV FROM KETQUA WHERE MaHP = p_MaHP
    );
  END IF;
END$$

/* 6. Procedure: Xếp loại tốt nghiệp */
DROP PROCEDURE IF EXISTS sp_Xep_Loai$$
CREATE PROCEDURE sp_Xep_Loai(IN p_MSSV VARCHAR(10), OUT p_Loai VARCHAR(50))
BEGIN
  DECLARE _tb FLOAT;
  CALL sp_DIEM_TB(p_MSSV, _tb);
  IF _tb = -1 THEN
    SET p_Loai = 'MSSV không tồn tại';
  ELSEIF _tb >= 3.6 THEN
    SET p_Loai = 'Xuat sac';
  ELSEIF _tb >= 3.2 THEN
    SET p_Loai = 'Gioi';
  ELSEIF _tb >= 2.5 THEN
    SET p_Loai = 'Kha';
  ELSE
    SET p_Loai = 'Khong dat';
  END IF;
END$$

/* 7. Procedure: Liệt kê SV theo loại tốt nghiệp */
DROP PROCEDURE IF EXISTS sp_SV_LOAI$$
CREATE PROCEDURE sp_SV_LOAI(IN p_Loai VARCHAR(50))
BEGIN
  SELECT s.MSSV, s.HoTen
  FROM SINHVIEN s
  WHERE (
    SELECT CASE
      WHEN IFNULL(SUM(kq.Diem * kq.SoTinChi)/SUM(kq.SoTinChi),0) >= 3.6 THEN 'Xuat sac'
      WHEN IFNULL(SUM(kq.Diem * kq.SoTinChi)/SUM(kq.SoTinChi),0) >= 3.2 THEN 'Gioi'
      WHEN IFNULL(SUM(kq.Diem * kq.SoTinChi)/SUM(kq.SoTinChi),0) >= 2.5 THEN 'Kha'
      ELSE 'Khong dat'
    END
    FROM KETQUA kq
    WHERE kq.MSSV = s.MSSV
  ) = p_Loai;
END$$

/* ----------- Functions ----------- */

/* 8. Function: Tổng số tiết học của SV */
DROP FUNCTION IF EXISTS fn_TotalCredits$$
CREATE FUNCTION fn_TotalCredits(p_MSSV VARCHAR(10)) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT IFNULL(SUM(h.SoTietLT + h.SoTietTH),0) INTO total
  FROM KETQUA k
  JOIN HOCPHAN h ON h.MaHP = k.MaHP
  WHERE k.MSSV = p_MSSV;
  RETURN total;
END$$

/* 9. Function: Kiểm tra tốt nghiệp */
DROP FUNCTION IF EXISTS fn_TOT_NGHIEP$$
CREATE FUNCTION fn_TOT_NGHIEP(p_MSSV VARCHAR(10)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE tb FLOAT;
  SELECT IFNULL(SUM(Diem * SoTinChi)/SUM(SoTinChi),0) INTO tb
  FROM KETQUA WHERE MSSV = p_MSSV;
  RETURN tb >= 2.5;
END$$

/* 10. Procedure: Số lượng SV tốt nghiệp theo khoa */
DROP PROCEDURE IF EXISTS sp_SL_SV_TOTNGHIEP$$
CREATE PROCEDURE sp_SL_SV_TOTNGHIEP(IN p_TenKhoa VARCHAR(100))
BEGIN
  SELECT COUNT(*) AS SoSV_TotNghiep
  FROM SINHVIEN s
  JOIN KHOA k ON s.MaKhoa = k.MaKhoa
  WHERE k.TenKhoa = p_TenKhoa
    AND fn_TOT_NGHIEP(s.MSSV);
END$$

DELIMITER ;

/* ----------- Triggers ----------- */
USE QLSV;
DELIMITER $$

/* 1. Trigger: Không cho MaSV rỗng khi INSERT */
DROP TRIGGER IF EXISTS trg_check_MaSV_not_empty$$
CREATE TRIGGER trg_check_MaSV_not_empty
BEFORE INSERT ON SINHVIEN
FOR EACH ROW
BEGIN
  IF NEW.MaSV IS NULL OR TRIM(NEW.MaSV) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MaSV khong duoc rong';
  END IF;
END$$

/* 2. Trigger: Không cho xóa SV lớp CT12 */
DROP TRIGGER IF EXISTS trg_prevent_delete_CT12$$
CREATE TRIGGER trg_prevent_delete_CT12
BEFORE DELETE ON SINHVIEN
FOR EACH ROW
BEGIN
  IF OLD.LopSV = 'CT12' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong duoc xoa sinh vien lop CT12';
  END IF;
END$$

/* 3. Trigger: Nếu NgayNhapHoc NULL thì set CURRENT_DATE */
DROP TRIGGER IF EXISTS trg_set_NgayNhapHoc$$
CREATE TRIGGER trg_set_NgayNhapHoc
BEFORE INSERT ON SINHVIEN
FOR EACH ROW
BEGIN
  IF NEW.NgayNhapHoc IS NULL THEN
    SET NEW.NgayNhapHoc = CURRENT_DATE();
  END IF;
END$$
DELIMITER ;

/* ----------- Transactions ----------- */
USE TransactionDB;

-- 4. Update balance 2 accounts
UPDATE accounts SET Balance = 3000.00 WHERE AccountID = 1;
UPDATE accounts SET Balance = 4000.00 WHERE AccountID = 2;

-- 5. Transfer money (commit)
SET autocommit = 0;
START TRANSACTION;
UPDATE accounts SET Balance = Balance - 1000.00 WHERE AccountID = 1;
UPDATE accounts SET Balance = Balance + 1000.00 WHERE AccountID = 2;
COMMIT;
SET autocommit = 1;

-- 6. Transfer money (rollback when insufficient funds)
SET autocommit = 0;
START TRANSACTION;
SELECT Balance INTO @bal FROM accounts WHERE AccountID = 1;
IF @bal < 50000.00 THEN
  ROLLBACK;
  SELECT 'Rollback vì không đủ tiền' AS ThongBao;
ELSE
  UPDATE accounts SET Balance = Balance - 50000.00 WHERE AccountID = 1;
  UPDATE accounts SET Balance = Balance + 50000.00 WHERE AccountID = 2;
  COMMIT;
END IF;
SET autocommit = 1;

/* ----------- Isolation Level ----------- */
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* ----------- Deadlock Simulation ----------- */
/* Session 1:
START TRANSACTION;
SELECT * FROM accounts WHERE AccountID = 1 FOR UPDATE;
DO SLEEP(5);
SELECT * FROM accounts WHERE AccountID = 2 FOR UPDATE;
COMMIT;

Session 2:
START TRANSACTION;
SELECT * FROM accounts WHERE AccountID = 2 FOR UPDATE;
DO SLEEP(5);
SELECT * FROM accounts WHERE AccountID = 1 FOR UPDATE;
COMMIT;
*/
