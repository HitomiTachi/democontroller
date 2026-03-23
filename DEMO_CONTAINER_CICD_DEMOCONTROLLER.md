# Huong Dan Demo Bai 6 va Bai 7 voi du an Democontroller

Tai lieu nay huong dan demo end-to-end tren chinh du an hien tai, gom:
- Bai 6: Container hoa Spring Boot bang Docker + Docker Compose
- Bai 7: Tu dong Build/Push Docker Image bang GitHub Actions

## 1) Tong quan du an hien tai

- Thu muc goc repo: `E:/Java/J2EE/democontroller`
- Ma nguon app: `E:/Java/J2EE/democontroller/democontroller`
- Build tool: Maven Wrapper (`mvnw`, `mvnw.cmd`)
- Java version trong `pom.xml`: `17`
- Endpoint de test:
  - Trang giao dien: `GET /home`
  - API: `GET /api/books`

Luu y quan trong:
- Cac lenh trong tai lieu nay duoc chay tu thu muc goc repo `E:/Java/J2EE/democontroller`.
- Vi app nam trong thu muc con `democontroller`, can dung dung duong dan khi build Docker.

---

## 2) Demo Bai 6 - Container voi Docker

### B2.1 - Chuan bi moi truong

1. Cai Docker Desktop va mo ung dung (Engine phai dang Running).
2. Kiem tra:

```powershell
docker --version
docker compose version
```

### B2.2 - Tao Dockerfile cho app Spring Boot

Tao file `Dockerfile` tai thu muc goc repo (`E:/Java/J2EE/democontroller`) voi noi dung:

```dockerfile
# Stage 1: Build JAR
FROM maven:3.9.11-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Run app
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### B2.3 - Build image

Chay lenh tai thu muc goc repo:

```powershell
docker build -t <dockerhub-username>/democontroller:local -f Dockerfile .
```

Vi du:

```powershell
docker build -t nguyenvana/democontroller:local -f Dockerfile .
```

### B2.3.1 - Build image tren giao dien Docker Desktop (GUI)

1. Mo Docker Desktop, dam bao dong chu `Engine running` mau xanh.
2. Mo tab `Images`:
   - Neu co nut `Build`: bam vao, chon:
     - Build context: `E:/Java/J2EE/democontroller`
     - Dockerfile: `E:/Java/J2EE/democontroller/Dockerfile`
     - Tag: `<dockerhub-username>/democontroller:local`
   - Neu khong co nut `Build`: mo tab `Terminal` trong Docker Desktop va chay lenh build o B2.3.
3. Sau khi build xong, quay lai tab `Images` va kiem tra image vua tao.

### B2.4 - Chay container

```powershell
docker run -d --name democontroller-app -p 8080:8080 <dockerhub-username>/democontroller:local
```

Kiem tra nhanh:

```powershell
docker ps
docker logs democontroller-app
```

Thu tren trinh duyet:
- `http://localhost:8080/home`
- `http://localhost:8080/api/books`

Dung va xoa container:

```powershell
docker stop democontroller-app
docker rm democontroller-app
```

### B2.4.1 - Chay container tren giao dien Docker Desktop (GUI)

1. Vao `Images` -> tim image `<dockerhub-username>/democontroller:local`.
2. Bam `Run`.
3. Cau hinh:
   - Container name: `democontroller-app`
   - Port mapping: `8080` (Host) -> `8080` (Container)
4. Bam `Run` de khoi dong.
5. Vao tab `Containers`:
   - Kiem tra trang thai `Running`.
   - Bam container de xem `Logs`.
   - Dung nut `Stop` hoac `Delete` khi ket thuc.

### B2.5 - Docker Compose (1 service app)

Tao file `docker-compose.yml` tai thu muc goc repo:

```yaml
services:
  app:
    build:
      context: ./democontroller
      dockerfile: Dockerfile
    image: <dockerhub-username>/democontroller:compose
    container_name: democontroller-app
    ports:
      - "8080:8080"
    restart: unless-stopped
```

Chay compose:

```powershell
docker compose up -d --build
docker compose ps
```

Kiem tra endpoint:
- `http://localhost:8080/home`
- `http://localhost:8080/api/books`

Tat demo:

```powershell
docker compose down
```

### B2.5.1 - Theo doi compose tren giao dien Docker Desktop (GUI)

1. Sau khi chay `docker compose up -d --build`, vao tab `Containers`.
2. Tim group theo ten project compose va xem cac service ben trong.
3. Bam vao service `app` de theo doi:
   - `Logs` (kiem tra app boot thanh cong)
   - `Inspect` (xem port, image, env)
4. Ket thuc demo bang `docker compose down`, sau do refresh tab `Containers` de xac nhan da tat.

### B2.6 - Script thuyet trinh ngan cho Bai 6

1. Neu van de "`Works on my machine`".
2. Trinh bay Dockerfile multi-stage (build va run tach rieng).
3. Build image 1 lan, chay o moi noi nhu nhau.
4. Dung Docker Compose de quan ly viec chay app.

---

## 3) Demo Bai 7 - CI/CD voi GitHub Actions + Docker Hub

Muc tieu: Moi lan push len nhanh `main`, GitHub se tu dong:
- Checkout code
- Build Docker image
- Login Docker Hub
- Push image len Docker Hub

### B3.1 - Day du an len GitHub

Neu chua co repo:
1. Tao repo tren GitHub.
2. Push code len nhanh `main`.

Thao tac GUI tren GitHub:
1. Vao [https://github.com/new](https://github.com/new).
2. Nhap ten repo (vi du: `democontroller`), chon `Public` hoac `Private`.
3. Bam `Create repository`.
4. Copy bo lenh push mac dinh GitHub hien ra va chay trong terminal.

### B3.2 - Tao Docker Hub Access Token

Tren Docker Hub:
1. Vao `Account Settings` -> `Security`.
2. Tao `Access Token`.
3. Luu token lai (chi hien 1 lan).

Thao tac GUI:
1. Dang nhap [https://hub.docker.com](https://hub.docker.com).
2. Chon avatar goc phai -> `Account Settings`.
3. Chon `Personal access tokens` hoac `Security`.
4. Bam `Generate new token`, dat ten (vi du `github-actions-token`), copy token.

### B3.3 - Tao GitHub Secrets

Vao repo GitHub -> `Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`:

- `DOCKERHUB_USERNAME` = username Docker Hub
- `DOCKERHUB_TOKEN` = access token Docker Hub

Thao tac GUI chi tiet:
1. Mo repo tren GitHub.
2. Chon tab `Settings` (tren thanh menu repo).
3. O menu trai, chon `Secrets and variables` -> `Actions`.
4. Bam `New repository secret` de tao tung secret:
   - Name: `DOCKERHUB_USERNAME`, Value: username cua ban
   - Name: `DOCKERHUB_TOKEN`, Value: token vua tao

### B3.4 - Tao workflow deploy

Tao file `.github/workflows/deploy.yml` tai thu muc goc repo:

```yaml
name: Build and Push Democontroller Image

on:
  push:
    branches: [ "main" ]

jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: |
            ${{ secrets.DOCKERHUB_USERNAME }}/democontroller:latest
            ${{ secrets.DOCKERHUB_USERNAME }}/democontroller:${{ github.sha }}
```

Luu y:
- `context` va `file` trong workflow phai khop vi tri Dockerfile hien tai (o root repo).

Thao tac GUI tao workflow tren GitHub:
1. Vao repo -> tab `Actions`.
2. Bam `set up a workflow yourself` (hoac `New workflow` -> `set up a workflow yourself`).
3. Dat ten file `deploy.yml`.
4. Dan noi dung workflow, bam `Commit changes`.

### B3.5 - Kich hoat pipeline

Tao thay doi nho va push:

```powershell
git add .
git commit -m "Add CI workflow for Democontroller"
git push origin main
```

Theo doi GUI:
1. Vao tab `Actions`.
2. Bam vao workflow run moi nhat.
3. Xem tung job/step:
   - `Checkout source`
   - `Login to Docker Hub`
   - `Build and push image`

### B3.6 - Kiem tra ket qua

1. Vao tab `Actions` tren GitHub.
2. Xem workflow chay:
   - mau vang: dang chay
   - mau xanh: thanh cong
   - mau do: loi
3. Vao Docker Hub kiem tra image:
   - `<dockerhub-username>/democontroller:latest`
   - `<dockerhub-username>/democontroller:<commit-sha>`

Thao tac GUI kiem tra Docker Hub:
1. Mo [https://hub.docker.com](https://hub.docker.com) -> `Repositories`.
2. Chon repo `democontroller`.
3. Vao tab `Tags` de kiem tra `latest` va tag SHA moi.

### B3.7 - Script thuyet trinh ngan cho Bai 7

1. CI: tu dong build khi push code.
2. CD: tu dong tao va dua image len Docker Hub.
3. Secrets: bao mat credential, khong hard-code trong repo.
4. Ket qua: giam thao tac tay, tang do on dinh khi release.

---

## 4) Kich ban demo goi y (10-15 phut)

### Phan A - Bai 6 (5-7 phut)

1. Gioi thieu nhanh cau truc du an va endpoint test.
2. Mo Dockerfile, giai thich 2 stage.
3. Chay `docker build`, `docker run`.
4. Mo trinh duyet `home` va `api/books`.
5. Chay `docker compose up -d --build` de ket thuc phan container.

### Phan B - Bai 7 (5-8 phut)

1. Mo file workflow `deploy.yml`.
2. Giai thich event `on: push` va cac steps chinh.
3. Push 1 commit mau.
4. Mo tab Actions de theo doi.
5. Mo Docker Hub de xac nhan image moi.

---

## 5) Loi thuong gap va cach xu ly nhanh

- `port is already allocated`:
  - Doi port host, vi du `"8081:8080"`, hoac stop container cu.

- Workflow loi buoc login Docker Hub:
  - Kiem tra lai 2 secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

- Workflow loi buoc build:
  - Kiem tra `context: .` va `file: ./Dockerfile` (theo cau truc hien tai).

- App khong len du endpoint:
  - Xem log container: `docker logs democontroller-app`.

---

## 6) Checklist truoc khi demo tren lop

- Docker Desktop dang running.
- Du an build duoc local (`mvnw clean package` trong thu muc `democontroller`).
- Da tao Dockerfile.
- Da tao `docker-compose.yml`.
- Da tao secrets tren GitHub.
- Da tao workflow `.github/workflows/deploy.yml`.
- Da kiem tra image xuat hien tren Docker Hub.

---

## 7) Lenh nhanh tong hop

```powershell
# Build image tu thu muc goc repo
docker build -t <dockerhub-username>/democontroller:local -f Dockerfile .

# Run app
docker run -d --name democontroller-app -p 8080:8080 <dockerhub-username>/democontroller:local

# Compose
docker compose up -d --build
docker compose down
```

Chuc ban demo tot - neu can, co the bo sung phien ban "script loi noi thuyet trinh tung phut" dua tren file nay.
