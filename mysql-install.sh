#!/bin/bash
set -e

echo "=========================================="
echo "  GCP e2-micro MySQL Docker 설치"
echo "=========================================="
echo ""

# 1. Docker가 설치되어 있는지 확인
if ! command -v docker &> /dev/null; then
    echo "❌ Docker가 설치되지 않았습니다."
    echo "먼저 Docker를 설치하세요."
    exit 1
fi

# 2. Swap 메모리 추가 (e2-micro 필수)
echo "💾 Swap 메모리 확인 중..."
if [ ! -f /swapfile ]; then
    echo "Swap 메모리 생성 중..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
    sudo sysctl vm.swappiness=10
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "✅ 2GB Swap 메모리 생성 완료"
else
    echo "✅ Swap 메모리가 이미 존재합니다"
fi
echo ""

# 3. MySQL 디렉토리 생성
echo "📁 MySQL 디렉토리 생성 중..."
mkdir -p ~/mysql-docker
cd ~/mysql-docker

# 4. docker-compose.yml 생성
echo "📄 docker-compose.yml 생성 중..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    restart: unless-stopped
    
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 300M
        reservations:
          memory: 200M
    
    environment:
      MYSQL_ROOT_PASSWORD: 1q2w3e4r!
      TZ: Asia/Seoul
    
    command: [
      '--character-set-server=utf8mb4',
      '--collation-server=utf8mb4_unicode_ci',
      '--default-authentication-plugin=mysql_native_password',
      '--innodb-buffer-pool-size=128M',
      '--innodb-log-file-size=32M',
      '--innodb-buffer-pool-instances=1',
      '--max-connections=50',
      '--thread-cache-size=8',
      '--table-open-cache=400',
      '--tmp-table-size=16M',
      '--max-heap-table-size=16M',
      '--performance-schema=OFF',
      '--skip-name-resolve'
    ]
    
    ports:
      - "3306:3306"
    
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
    driver: local
EOF

# 5. MySQL 컨테이너 시작
echo ""
echo "🚀 MySQL 컨테이너 시작 중..."
docker compose up -d

# 6. 상태 확인
echo ""
echo "⏳ MySQL 초기화 대기 중 (30초)..."
sleep 30

# 7. 설치 완료
echo ""
echo "=========================================="
echo "  ✅ MySQL 설치 완료!"
echo "=========================================="
echo ""
echo "📊 컨테이너 상태:"
docker compose ps
echo ""
echo "📝 접속 정보:"
echo "   호스트: localhost (또는 VM 외부 IP)"
echo "   포트: 3306"
echo ""
echo "🔧 유용한 명령어:"
echo "   docker compose logs -f          # 로그 확인"
echo "   docker compose exec mysql bash  # MySQL 컨테이너 접속"
echo "   docker compose down             # MySQL 중지"
echo "   docker compose up -d            # MySQL 시작"
echo ""