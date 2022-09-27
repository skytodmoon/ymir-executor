ARG PYTORCH="1.8.0"
ARG CUDA="11.1"
ARG CUDNN="8"

# cuda11.1 + pytorch 1.9.0 + cudnn8 not work!!!
FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-runtime

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"
ENV LANG=C.UTF-8

# Install linux package
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
RUN	apt-get update && apt-get install -y gnupg2 git libglib2.0-0 \
    libgl1-mesa-glx curl wget zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple

# install ymir-exc sdk
WORKDIR /workspace
RUN wget https://github.com/yzbx/ymir-executor-fork/releases/download/dataset/executor.zip -O /workspace/executor.zip
#COPY ./executor.zip /workspace
RUN unzip executor.zip && pip install -e /workspace/executor

# Copy file from host to docker and install requirements
ADD ./det-yolov3-tmi /app
RUN mkdir /img-man && mv /app/*-template.yaml /img-man/ \
    && pip install -r /app/requirements.txt \
	&& pip install -U numpy typing-extensions

# Download pretrained weight and font file
# COPY ./yolov5*.pt /app/
RUN cd /app && bash data/scripts/download_weights.sh \
    && mkdir -p /root/.config/Ultralytics \
    && wget https://ultralytics.com/assets/Arial.ttf -O /root/.config/Ultralytics/Arial.ttf

# Make PYTHONPATH find local package
ENV PYTHONPATH=.

WORKDIR /app
RUN echo "python3 /app/start.py" > /usr/bin/start.sh
CMD python3 /app/start.py