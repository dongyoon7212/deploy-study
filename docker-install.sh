#!/bin/bash
set -e

echo "=========================================="
echo "  GCP e2-micro 최신 Docker 완전 설치"
echo "=========================================="
echo ""

# 1. 기존 Docker 완전 제거
echo "📦 1단계: 기존 Docker 완전 제거 중..."
sudo systemctl stop docker 2>/dev/null || true
sudo apt-get remove -y docker docker-engine docker.io containerd runc docker-compose 2>/dev/null || true
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker
sudo apt-get autoremove -y
echo "✅ 기존 Docker 제거 완료"
echo ""

# 2. 시스템 업데이트 및 필수 패키지 설치
echo "📦 2단계: 시스템 업데이트 및 필수 패키지 설치 중..."
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common
echo "✅ 필수 패키지 설치 완료"
echo ""

# 3. Docker 공식 GPG 키 추가
echo "🔑 3단계: Docker 공식 GPG 키 추가 중..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "✅ GPG 키 추가 완료"
echo ""

# 4. Docker 저장소 추가
echo "📚 4단계: Docker 저장소 추가 중..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "✅ Docker 저장소 추가 완료"
echo ""

# 5. 최신 Docker Engine 설치
echo "🐳 5단계: 최신 Docker Engine 설치 중..."
sudo apt-get update
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
echo "✅ Docker Engine 설치 완료"
echo ""

# 6. 현재 사용자를 docker 그룹에 추가
echo "👤 6단계: 사용자 권한 설정 중..."
sudo usermod -aG docker $USER
echo "✅ 사용자 '$USER'를 docker 그룹에 추가 완료"
echo ""

# 7. Docker 서비스 시작 및 활성화
echo "⚙️  7단계: Docker 서비스 시작 중..."
sudo systemctl enable docker
sudo systemctl start docker
echo "✅ Docker 서비스 시작 완료"
echo ""

# 8. Swap 메모리 추가 (e2-micro 필수!)
echo "💾 8단계: Swap 메모리 추가 중..."
if [ ! -f /swapfile ]; then
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

# 9. Docker Buildx 기본 빌더 설정
echo "🔨 9단계: Docker Buildx 설정 중..."
docker buildx create --use --name mybuilder 2>/dev/null || true
echo "✅ Buildx 설정 완료"
echo ""

# 10. 설치 확인
echo "=========================================="
echo "  ✅ 설치 완료!"
echo "=========================================="
echo ""
echo "📊 설치된 버전:"
docker --version
docker compose version
echo ""
echo "💾 메모리 상태:"
free -h
echo ""
echo "⚠️  중요: 다음 명령어 중 하나를 실행하세요:"
echo "   1) newgrp docker          # 현재 세션에 권한 적용 (권장)"
echo "   2) SSH 재접속            # 또는 재로그인"
echo ""
echo "🎉 이후 'docker' 명령어를 sudo 없이 사용할 수 있습니다!"
echo ""
