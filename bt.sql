USE master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE Name='Project')
DROP DATABASE Project
GO
CREATE DATABASE Project
GO
USE Project
GO

CREATE TABLE PhongBan(
	MaPB varchar(7) primary key,
	TenPB nvarchar(50) NOT NULL
)

CREATE TABLE NhanVien(
	MaNV varchar(7) primary key,
	TenNV nvarchar(50) NOT NULL,
	NgaySinh Date check (NgaySinh < (getDATE())) DEFAULT '1996-07-17',
	SoCMND char(9) check (SoCMND not like '%[^0-9]%'),
	GioiTinh char(1) check(GioiTinh not like '%[^F,M]%' )  DEFAULT 'M' ,
	DiaChi nvarchar(100),
	NgayVaoLam Datetime  DEFAULT  getdate(),
	MaPB varchar(7),
	CONSTRAINT FK_NV_PB
    FOREIGN KEY (MaPB)
    REFERENCES PhongBan(MaPB),
	CONSTRAINT CK_NS_NVL CHECK (DATEDIFF(year,Ngaysinh,NgayVaoLam )>20)
)
CREATE TABLE LuongDA(
	MaDA varchar(8),
	MaNV varchar(7),
	primary key(MaDA,MaNV),
	NgayNhan datetime NOT NULL default getdate(),
	SoTien money check (SoTien > 0)
	CONSTRAINT FK_MDA_MNV
    FOREIGN KEY (MaNV)
    REFERENCES NhanVien(MaNV)
)

INSERT INTO  PhongBan Values('PB1','phong xay dung')
INSERT INTO  PhongBan Values('PB2','phong ban buon')
INSERT INTO  PhongBan Values('PB3','phong ban le')
INSERT INTO  PhongBan Values('PB4','phong thiet ke')
INSERT INTO  PhongBan Values('PB5','phong quang cao')
SELECT * FROM PhongBan

INSERT INTO  NhanVien Values('NV1','Son','1996-07-17','123456789','M','HaNOi','2022-01-10','PB5')
INSERT INTO  NhanVien Values('NV2','Tu','2000-01-11','987654321','M','HaNOi','2022-01-10','PB5')
INSERT INTO  NhanVien Values('NV3','LongCong','1998-01-10','222244445','F','HaNOi','2022-01-10','PB1')
INSERT INTO  NhanVien Values('NV4','Trieu Man','1999-01-10','123123239','F','HaNOi','2022-01-10','PB1')
INSERT INTO  NhanVien Values('NV5','Tieu Yen Tu','2001-01-10','123456456','F','HaNOi','2022-01-10','PB2')
INSERT INTO  NhanVien Values('NV6','B','2001-01-10','123456456','F','HaNOi','2022-01-10','PB2')
INSERT INTO  NhanVien Values('NV7','C','2001-01-10','123456456','F','HaNOi','2022-01-10','PB2')
INSERT INTO  NhanVien Values('NV8','Nhan','2001-01-10','123456456','F','HaNOi','2022-01-10','PB2')


SELECT * FROM NhanVien

INSERT INTO  LuongDA Values('DA1','NV1','',1000)
INSERT INTO  LuongDA Values('DA2','NV2','2022-01-10',100)
INSERT INTO  LuongDA Values('DA3','NV3','2010-01-10',200)
INSERT INTO  LuongDA Values('DA4','NV4','2012-01-10',50)
INSERT INTO  LuongDA Values('DA5','NV5','2008-01-10',10)
INSERT INTO  LuongDA Values('DA6','NV7','2003-01-10',10)

SELECT * FROM LuongDA

--2. Viết một query để hiển thị thông tin về các bảng LUONGDA, NHANVIEN, PHONGBAN.
SELECT * FROM LuongDA,NhanVien,PhongBan
--3. Viết một query để hiển thị những nhân viên có giới tính là ‘F’.
SELECT * FROM NhanVien WHERE GioiTinh like 'f'

--4. Hiển thị tất cả các dự án, mỗi dự án trên 1 dòng.
SELECT MaDA FROM LuongDA

--5. Hiển thị tổng lương của từng nhân viên (dùng mệnh đề GROUP BY).
SELECT TenNV, SUM(SoTien) AS 'Tong'
FROM LuongDA, NhanVien
where TenNV like 'son'
GROUP BY TenNV

--6. Hiển thị tất cả các nhân viên trên một phòng ban cho trước (VD: ‘Hành chính’).
SELECT * FROM NhanVien WHERE MaPB
IN
(SELECT MaPB FROM PhongBan WHERE TenPB like '%quang cao%')

--7. Hiển thị mức lương của những nhân viên phòng hành chính.
SELECT SoTien FROM LuongDA WHERE MaNV
IN
(SELECT MaNV FROM NhanVien WHERE MaPB 
IN
(SELECT MaPB FROM PhongBan WHERE TenPB like '%quang cao%'))


--8. Hiển thị số lượng nhân viên của từng phòng.
SELECT TenPB FROM PhongBan WHERE MaPB
IN
(SELECT MaPB FROM NhanVien)

--9. Viết một query để hiển thị những nhân viên mà tham gia ít nhất vào một dự án.
SELECT TenNV FROM NhanVien WHERE MaNV
IN
(SELECT MaNV FROM LuongDA)

--10. Viết một query hiển thị phòng ban có số lượng nhân viên nhiều nhất.
SELECT TenPB FROM PhongBan WHERE MaPB
IN
(SELECT MaPB FROM NhanVien WHERE MaPB = (SELECT max(MaPB) FROM NhanVien))
--11. Tính tổng số lượng của các nhân viên trong phòng Hành chính.
SELECT SUM(SoTien) as'tong luong phong quang cao' FROM LuongDA where MaNV
IN
(SELECT MaNV FROM NhanVien WHERE MaPB 
IN
(SELECT MaPB FROM PhongBan WHERE TenPB like '%quang cao%'))
--12. Hiển thị tống lương của các nhân viên có số CMND tận cùng bằng 9.
SELECT SUM(SoTien) as'tong luong NV co so CMND cuoi la 9' FROM LuongDA where MaNV
IN
(SELECT MaNV FROM NhanVien WHERE SoCMND like '%9')
--13. Tìm nhân viên có số lương cao nhất.
SELECT MaNv,TenNV FROM NhanVien WHERE MaNV
IN
(SELECT MaNV FROM LuongDA WHERE SoTien = (SELECT MAX(SoTien) FROM LuongDA))


--14. Tìm nhân viên ở phòng Hành chính có giới tính bằng ‘F’ và có mức lương > 1200000.
SELECT TenNV FROM NhanVien WHERE GioiTinh = 'F' and MaPB
IN
(SELECT MaPB FROM PhongBan WHERE TenPB like '%xay dung%') and MaNV
IN
(SELECT MaNV FROM LuongDA WHERE SoTien > 100)

--15. Tìm tổng lương trên từng phòng.
	select TenPB,sum(sotien) as 'Tong luong cua tung phong ban'
	from (LuongDA inner join NhanVien on LuongDA.MaNV = NhanVien.MaNV) 
	right join PhongBan on NhanVien.MaPB=PhongBan.MaPB group by TenPB

--16. Liệt kê các dự án có ít nhất 2 người tham gia.
	select LuongDA.MaDA,count(LuongDA.MaDA) as 'So nguoi tham gia' from LuongDA 
	group by LuongDA.MaDA having count(LuongDA.MaDA)>1

--17. Liệt kê thông tin chi tiết của nhân viên có tên bắt đầu bằng ký tự ‘N’.
SELECT * FROM NhanVien WHERE TenNV like 'N%'

--18. Hiển thị thông tin chi tiết của nhân viên được nhận tiền dự án trong năm 2003.
SELECT * FROM NhanVien WHERE MaNV
IN
(SELECT MaNV FROM LuongDA WHERE NgayNhan < '2003-30-12' and NgayNhan > '2003-01-01')

--19. Hiển thị thông tin chi tiết của nhân viên không tham gia bất cứ dự án nào.
SELECT * FROM NhanVien
left Join  LuongDA ON
NhanVien.MaNV = LuongDA.MaNV  WHERE MaDA is null

--20. Xoá dự án có mã dự án là DXD02.
DELETE FROM LuongDA WHERE MaDA like 'DA6'

--21. Xoá đi từ bảng LuongDA những nhân viên có mức lương 2000000.
DELETE FROM LuongDA WHERE SoTien = 10

--22. Cập nhật lại lương cho những người tham gia dự án XDX01 thêm 10% lương cũ.

--23. Xoá các bản ghi tương ứng từ bảng NhanVien đối với những nhân viên không có mã nhân viên
--tồn tại trong bảng LuongDA.

delete from NhanVien WHERE TenNV = 
(SELECT TenNV FROM NhanVien
left Join  LuongDA ON
NhanVien.MaNV = LuongDA.MaNV  WHERE MaDA is null)

--24. Viết một truy vấn đặt lại ngày vào làm của tất cả các nhân viên thuộc phòng hành chính là ngày
--12/02/1999
UPDATE NhanVien SET DiaChi = 'HP'  WHERE MaPB = (SELECT MaPB FROM PhongBan WHERE TenPB like '%xay dung%' )