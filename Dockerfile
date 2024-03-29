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
COPY roop roop/
RUN mkdir models

#Download Models 
RUN wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth -P models/ && \
	wget https://huggingface.co/CountFloyd/deepfake/resolve/main/inswapper_128.onnx -P models/
#Install buffalo
RUN    cd /root && mkdir -p .insightface/models/buffalo_l && \
    cd .insightface/models/buffalo_l && \	
    wget https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip && \
    unzip buffalo_l.zip && \
    rm -f buffalo_l.zip 
#Install opennsfw2/
RUN    cd /root && mkdir -p .opennsfw2/weights && \
    cd .opennsfw2/weights && \	
    wget  https://github.com/bhky/opennsfw2/releases/download/v0.1.0/open_nsfw_weights.h5

RUN mkdir -p /workspace/gfpgan/weights && \
    cd /workspace/gfpgan/weights && \
    wget https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth && \
    wget https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth 
ENTRYPOINT ./start.sh 
