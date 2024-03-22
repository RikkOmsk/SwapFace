FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash


# Set up system
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends git unzip wget curl python3-tk bash ffmpeg libgl1 p7zip-full software-properties-common openssh-server nginx && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt install python3.10-dev python3.10-venv -y --no-install-recommends && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
# # Set up Python and pip
# RUN ln -s /usr/bin/python3.10 /usr/bin/python && \
#     rm /usr/bin/python3 && \
#     ln -s /usr/bin/python3.10 /usr/bin/python3 && \
#     curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
#     python get-pip.py

WORKDIR /workspace

COPY requirements.txt . 
RUN pip install --no-cache-dir torch==2.2.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip install --no-cache-dir -r requirements.txt && \
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
