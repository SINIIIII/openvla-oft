# 1. Base Image: GPU 지원 및 flash-attn 컴파일을 위한 CUDA 12.1.1 Devel 이미지 사용
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# 시간대 설정 등 apt-get 설치 시 발생하는 상호작용(프롬프트) 방지
ENV DEBIAN_FRONTEND=noninteractive

# 2. 시스템 의존성 설치 (Python 3.10, git, 빌드 툴 등)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    python3.10 \
    python3.10-dev \
    python3-pip \
    ninja-build \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 3. Python 3.10을 기본 python 명령어로 설정
RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

# pip 최신 버전으로 업그레이드
RUN python -m pip install --upgrade pip

# 4. 작업 디렉토리 설정
WORKDIR /workspace/openvla-oft

# 5. 소스 코드 및 설정 파일 복사
# (실제 빌드 시 Dockerfile이 있는 디렉토리의 모든 파일이 복사됩니다)
COPY . /workspace/openvla-oft

# 6. PyTorch 설치 (CUDA 12.1 버전에 맞는 2.2.0 버전 설치)
RUN pip install torch==2.2.0 torchvision==0.17.0 torchaudio==2.2.0 --index-url https://download.pytorch.org/whl/cu121

# 7. flash-attn 설치를 위한 의존성 설치
RUN pip install packaging ninja

# 8. 프로젝트 패키지 및 의존성 설치 (pyproject.toml 기반)
# git 저장소 기반 패키지(transformers, dlimp)들도 이 단계에서 함께 설치됩니다.
RUN pip install -e .

# 9. Flash Attention 2 설치 (SETUP.md 지침 반영)
RUN pip install "flash-attn==2.5.5" --no-build-isolation

# 10. 컨테이너 실행 시 기본 실행 명령어 (Bash 쉘)
CMD ["/bin/bash"]