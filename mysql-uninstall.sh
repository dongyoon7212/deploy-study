#!/bin/bash
set -e

echo "=========================================="
echo "  MySQL Docker 완전 제거"
echo "=========================================="
echo ""

# 1. MySQL 컨테이너 중지 및 삭제
echo "🛑 MySQL 컨테이너 중지 및 삭제 중..."
cd ~/mysql-docker
docker compose down -v  # -v 옵션으로 볼륨까지 삭제

# 2. MySQL 이미지 삭제
echo "🗑️  MySQL 이미지 삭제 중..."
docker rmi mysql:8.0 2>/dev/null || echo "이미지가 이미 삭제되었거나 없습니다"

# 3. mysql-docker 디렉토리 삭제
echo "📁 mysql-docker 디렉토리 삭제 중..."
cd ~
rm -rf ~/mysql-docker

# 4. 고아 볼륨 정리 (선택)
echo "🧹 사용하지 않는 Docker 볼륨 정리 중..."
docker volume prune -f

echo ""
echo "=========================================="
echo "  ✅ MySQL 완전 제거 완료!"
echo "=========================================="
echo ""
echo "📊 남은 컨테이너:"
docker ps -a
echo ""
echo "📦 남은 볼륨:"
docker volume ls
echo ""
echo "💡 이제 설치 스크립트를 다시 실행하세요!"
