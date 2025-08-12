CREATE DATABASE QLDIEM;
USE QLDIEM;

CREATE TABLE khoa (
    maKhoa CHAR(8) PRIMARY KEY,
    tenKhoa VARCHAR(50)
);

CREATE TABLE sinhVien (
    mssv CHAR(8) PRIMARY KEY,
    hoTen VARCHAR(45),
    gioiTinh CHAR(1),
    ngaySinh DATE,
    noiSinh VARCHAR(40),
    diaChi VARCHAR(100),
    maKhoa CHAR(8),
    FOREIGN KEY (maKhoa) REFERENCES khoa(maKhoa)
);

CREATE TABLE ketQua (
    mssv CHAR(8),
    maHP CHAR(6),
    diem FLOAT,
    PRIMARY KEY (mssv, maHP),
    FOREIGN KEY (mssv) REFERENCES sinhVien(mssv),
    FOREIGN KEY (maHP) REFERENCES hocPhan(maHP)
);

CREATE TABLE hocPhan (
    maHP CHAR(6) PRIMARY KEY,
    tenHP VARCHAR(50),
    soTinChi INT,
    soTietLT INT,
    soTietTH INT
);

INSERT INTO khoa (maKhoa, tenKhoa) VALUES
('NNG', 'Khoa Ngoại ngữ'),
('CNTT&TT', 'Công nghệ thông tin và Truyền thông'),
('TN', 'Khoa Khoa học tự nhiên'),
('TS', 'Khoa Thủy sản'),
('SP', 'Khoa Sư phạm'),
('KT', 'Khoa Kinh tế');

INSERT INTO sinhVien (mssv, hoTen, gioiTinh, ngaySinh, noiSinh, diaChi, maKhoa) VALUES
('B1234567', 'Nguyễn Thanh Hải', 'M', '2000-12-02', 'Bạc Liêu', 'Phòng 01, KTX Khu B, ĐHCT', 'CNTT&TT'),
('B1234568', 'Trần Thanh Mai', 'M', '2001-01-20', 'Cần Thơ', '232, Nguyễn Văn Khéo, quận Ninh Kiều, TPCT', 'CNTT&TT'),
('B1234569', 'Trần Thu Thủy', 'F', '2001-07-01', 'Cần Thơ', '02, Đại lộ Hòa Bình, quận Ninh Kiều, TPCT', 'CNTT&TT'),
('B1334569', 'Nguyễn Thị Trúc Mã', 'F', '2002-05-25', 'Sóc Trăng', '343, Đường 30/4, quận Ninh Kiều, TPCT', 'SP'),
('B1345678', 'Trần Hồng Trúc', 'F', '2002-03-02', 'Cần Thơ', '123, Trần Hưng Đạo, quận Ninh Kiều, TPCT', 'CNTT&TT'),
('B1345679', 'Bùi Hoàng Yến', 'F', '2001-11-05', 'Vĩnh Long', 'Phòng 201, KTX Khu A, TPCT', 'CNTT&TT'),
('B1345680', 'Trần Minh Tâm', 'M', '2001-02-04', 'Cà Mau', '07, Đại lộ Hòa Bình, quận Ninh Kiều, TPCT', 'KT'),
('B1456789', 'Nguyễn Hồng Thắm', 'F', '2003-05-09', 'An Giang', '133, Nguyễn Văn Cừ, quận Ninh Kiều, TPCT', 'NNG'),
('B1459230', 'Lê Văn Khang', 'M', '2002-06-02', 'Đồng Tháp', '312, Nguyễn Văn Linh, quận Ninh Kiều, TPCT', 'TN'),
('B1456790', 'Lê Khải Hoàng', 'M', '2002-07-03', 'Kiên Giang', '03, Trần Hoàng Na, quận Ninh Kiều, TPCT', 'KT');

INSERT INTO hocPhan (maHP, tenHP, soTinChi, soTietLT, soTietTH) VALUES
('CT101', 'Lập trình căn bản', 4, 30, 60),
('CT176', 'Lập trình Hướng đối tượng', 3, 30, 30),
('CT237', 'Nguyên lý Hệ điều hành', 3, 30, 30),
('TN001', 'Vi tích phân A1', 3, 45, 0),
('TN101', 'Xác suất thống kê', 3, 45, 0),
('SP102', 'Đại số tuyến tính', 4, 60, 0),
('TN172', 'Toán rời rạc', 4, 60, 0),
('XH023', 'Anh văn căn bản 1', 4, 60, 0),
('TN021', 'Hóa học đại cương', 3, 60, 0);

INSERT INTO ketQua (mssv, maHP, diem) VALUES
('B1234567', 'CT101', 4),
('B1234568', 'CT176', 8),
('B1234569', 'CT237', 9),
('B1334569', 'SP102', 2),
('B1345678', 'CT101', 6),
('B1345679', 'CT176', 5),
('B1456789', 'TN172', 10),
('B1459230', 'TN172', 7),
('B1456789', 'XH023', 6),
('B1459230', 'XH023', 8),
('B1234567', 'CT176', 1),
('B1234568', 'CT101', 9),
('B1234569', 'CT101', 8),
('B1334569', 'CT101', 4),
('B1345678', 'TN001', 6),
('B1345679', 'CT101', 2),
('B1456789', 'CT101', 7),
('B1456790', 'TN101', 6),
('B1345680', 'TN101', 7),
('B1345680', 'XH023', 7);

-- Cau 1
select mssv, hoTen, gioiTinh, noiSinh
from sinhVien
order by mssv asc;

-- Cau 2
select mssv, hoTen, ngaySinh, maKhoa
from sinhVien
where hoTen not like 'L%' and hoTen not like 'T%';

-- Cau 3
select mssv, hoTen, year(curdate())-year(ngaySinh) as tuoi
from sinhVien
where year(curdate())-year(ngaySinh) between 20 and 22;

-- Cau 4
select maHP, tenHP
from hocPhan
where soTinChi = 3 and soTietLT >= 45;

-- Cau 5
select mssv, hoTen, gioiTinh
from sinhVien
where gioiTinh = 'M' and maKhoa = 'CNTT&TT';

-- Cau 6
select maHP, tenHP
from hocPhan
where maHP not in (select distinct maHP from ketQua);

-- Cau 7
select sinhVien.mssv, hoTen, maHP, diem
from sinhVien
join ketQua on sinhVien.mssv = ketQua.mssv
where diem < 5;

-- Cau 8
select sinhVien.mssv, hoTen
from sinhVien
join ketQua k1 on sinhVien.mssv = k1.mssv and k1.maHP = 'CT101'
join ketQua k2 on sinhVien.mssv = k2.mssv and k2.maHP = 'CT176';

-- Cau 9
select sinhVien.mssv, hoTen, maKhoa, diem
from sinhVien
join ketQua on sinhVien.mssv = ketQua.mssv
order by sinhVien.maKhoa asc, hoTen asc;

-- Cau 10
select hoTen, maHP
from sinhVien
join ketQua on sinhVien.mssv = ketQua.mssv
where ketQua.maHP = 'CT101' and diem between 5 and 7;

-- Cau 11
select hocPhan.maHP , hoTen
from sinhVien
join ketQua on sinhVien.mssv = ketQua.mssv
join hocPhan on hocPhan.maHP = ketQua.maHP
where soTietTH = 0;

-- Cau 12
select hocPhan.maHP, tenHP
from hocPhan
join ketQua on hocPhan.maHP = ketQua.maHP
group by hocPhan.maHP, tenHP
order by count(ketQua.mssv) desc
limit 1;

-- Cau 13
select hocPhan.maHP, count(mssv) as diem_duoi_5
from hocPhan
left join ketQua on hocPhan.maHP = ketQua.maHP and diem < 5
group by hocPhan.maHP;

-- Cau 14
select khoa.maKhoa, tenKhoa, count(mssv) as sv_trong_khoa
from khoa
left join sinhVien on khoa.maKhoa = sinhVien.maKhoa
group by khoa.maKhoa, tenKhoa;

-- Cau 15
select sinhVien.mssv, hoTen
from sinhVien
join ketQua on sinhVien.mssv = ketQua.mssv
group by sinhVien.mssv, hoTen
order by avg(ketQua.diem) desc
limit 1;

-- Cau 16
select khoa.maKhoa, khoa.tenKhoa,
       (select count(*) 
        from sinhVien 
        where sinhVien.maKhoa = khoa.maKhoa and sinhVien.gioiTinh = 'M') as soNam,
       (select count(*) 
        from sinhVien 
        where sinhVien.maKhoa = khoa.maKhoa and sinhVien.gioiTinh = 'F') as soNu
from khoa;

-- Cau 17
select sinhVien.mssv, hoTen, maKhoa
from sinhVien
where sinhVien.mssv not in (select ketQua.mssv
							from ketQua
                            where maHP = 'XH023');
                            
-- Cau 18
select sinhVien.mssv, hoTen
from sinhVien
join ketQua on sinhVien.mssv = ketQua.mssv
where ketQua.maHP = 'XH023'
order by diem desc
limit 1;

-- Cau 19
alter table ketQua
add constraint gioiHanDiem check (diem >= 0 and diem <= 10);
-- Cau 20
alter table sinhVien
add constraint dieuKienchoMSSV check (mssv regexp '^[A-Z][0-9]+$');
