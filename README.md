HƯỚNG DẪN CÁCH CHẠY:
Bước 1: git clone https://github.com/Joangf/ShopeeDupe
Bước 2: tải docker desktop, mở docker desktop
Bước 3: docker compose up shop-db -d
Bước 4: vào docker desktop mở container shop-db
Bước 5: vào exec nhập mysql -u root -p, sau đó nhập password root
Nếu muốn xoá hết database làm lại từ đầu thì docker compose down -v sau đó làm bước 3
netstat -aon | findstr 3306
taskkill /PID <PID> /F /T
docker exec -it shop-db mysql -u root -p