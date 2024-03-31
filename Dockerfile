FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
#COPY ./ /
ENV SHELL=/bin/bash \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Set up system
# Upgrade apt packages and install required dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
      python3-dev \
      python3-pip \
      python3.10-venv \
      python3-tk \
      fonts-dejavu-core \
      rsync \
      git \
      git-lfs \
      jq \
      moreutils \
      aria2 \
      wget \
      curl \
      libglib2.0-0 \
      libsm6 \
      libgl1 \
      libxrender1 \
      libxext6 \
      ffmpeg \
      unzip \
      libgoogle-perftools-dev \
      procps && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y
WORKDIR /workspace
COPY requirements.txt . 
RUN pip install --upgrade --force-reinstall  torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip install --upgrade --no-cache-dir -r requirements.txt && \
    pip uninstall -y onnxruntime && \
    pip install onnxruntime-gpu
RUN pip install --no-cache-dir runpod
RUN pip install --no-cache-dir wget
RUN pip install --no-cache-dir google-cloud
RUN pip install --upgrade google-cloud-storage

COPY start.sh . 
COPY run.py .
COPY rp_handler.py . 
COPY facefusion.ini .
COPY install.py .
COPY tests tests/
COPY facefusion facefusion/
RUN mkdir models

#Download Models 
RUN wget https://github.com/facefusion/facefusion-assets/releases/download/models/face_occluder.onnx -P .assets/models/ && \
	wget https://github.com/facefusion/facefusion-assets/releases/download/models/face_parser.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/codeformer.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/gfpgan_1.4.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/open_nsfw.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/retinaface_10g.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/scrfd_2.5g.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/yoloface_8n.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/yunet_2023mar.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/arcface_w600k_r50.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/arcface_simswap.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/2dfan4.onnx -P .assets/models/ && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/gender_age.onnx -P .assets/models/

ENTRYPOINT ./start.sh 
