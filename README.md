# Bài tập 1: Khởi tạo môi trường phát triển cơ bản với Docker Compose

## 1. Mục tiêu
Hiểu và áp dụng cấu trúc cơ bản của `docker-compose.yml` để chạy nhiều container (Backend Spring Boot và Database PostgreSQL) trên cùng một mạng nội bộ.

---

## 2. Nguyên nhân lỗi kết nối & Cơ chế mạng của Docker Compose

### 2.1. Tại sao dùng `localhost` lại gây lỗi `Connection refused`?
* Trong kiến trúc Docker, mỗi container được phân bổ một không gian mạng (**Network Namespace**) hoàn toàn độc lập, sở hữu địa chỉ IP nội bộ riêng và giao diện mạng loopback riêng (`localhost` hay `127.0.0.1`).
* Khi cấu hình `SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/storex`, chuỗi `localhost` trỏ trực tiếp đến chính container `backend`. Vì bên trong container `backend` không chạy dịch vụ PostgreSQL nào ở cổng 5432, yêu cầu kết nối ngay lập tức bị từ chối (`Connection refused`).

### 2.2. Cơ chế mạng nội bộ của Docker Compose (Docker Internal DNS)
* Khi khởi chạy bằng Docker Compose, Docker sẽ tự động tạo một mạng cầu (**Default Bridge Network**) và kết nối tất cả các service được định nghĩa trong file vào mạng này.
* Docker tích hợp sẵn một máy chủ DNS nội bộ (**Embedded DNS server** tại địa chỉ `127.0.0.11`). DNS server này có khả năng phân giải tự động các **Service Name** (tên dịch vụ) thành địa chỉ IP nội bộ của container tương ứng.
* Do đó, để container `backend` giao tiếp được với container PostgreSQL, ta chỉ cần thay thế hostname `localhost` bằng tên service là `postgres`:
  $$\text{jdbc:postgresql://postgres:5432/storex}$$

---

## 3. Nội dung file `docker-compose.yml` sau khi sửa

```yaml
version: '3.8'

services:
  backend:
    image: storex-backend:latest
    ports:
      - "8080:8080"
    environment:
      # Đã sửa: trỏ vào tên service 'postgres' thay vì 'localhost'
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/storex
      - SPRING_DATASOURCE_USERNAME=postgres
      - SPRING_DATASOURCE_PASSWORD=secret
    depends_on:
      - postgres
    restart: always

  postgres:
    image: postgres:13
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=storex
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: always

volumes:
  postgres_data:
```

### Các cải tiến bổ sung (Best Practices):
1. **`depends_on: - postgres`**: Đảm bảo container cơ sở dữ liệu `postgres` được tạo và khởi động trước `backend`.
2. **`volumes: postgres_data`**: Giữ dữ liệu của PostgreSQL bền vững, không bị mất khi stop/remove container.
3. **`restart: always`**: Tự động khôi phục container nếu gặp sự cố.

---

## 4. Hướng dẫn chạy và kiểm tra kết quả

### Bước 1: Khởi động hệ thống
```bash
docker compose up -d
```

### Bước 2: Kiểm tra trạng thái các container
```bash
docker compose ps
```
Cả hai service `backend` và `postgres` đều phải có trạng thái `Up`.

### Bước 3: Xem log của Backend
```bash
docker compose logs -f backend
```

**Log kỳ vọng khi kết nối thành công:**
```text
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.0)

INFO 1 --- [main] c.s.storex.StorexApplication            : Starting StorexApplication v0.0.1-SNAPSHOT
INFO 1 --- [main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
INFO 1 --- [main] com.zaxxer.hikari.pool.HikariPool        : HikariPool-1 - Added connection org.postgresql.jdbc.PgConnection@3a82f6e9
INFO 1 --- [main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
INFO 1 --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 8080 (http) with context path ''
INFO 1 --- [main] c.s.storex.StorexApplication            : Started StorexApplication in 3.14 seconds
```
