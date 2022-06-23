ARG PYTORCH="1.8.0"
ARG CUDA="11.1"
ARG CUDNN="8"
ARG PIP_SOURCE=https://pypi.mirrors.ustc.edu.cn/simple
# cuda11.1 + pytorch 1.9.0 + cudnn8 not work!!!
FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-runtime
ARG SERVER_MODE=prod

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"
ENV LANG=C.UTF-8

# Install linux package
RUN	apt-get update && apt-get install -y gnupg2 git libglib2.0-0 \
    libgl1-mesa-glx curl wget zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install ymir-exc sdk
RUN if [ "${SERVER_MODE}" = "dev" ]; then \
        pip install --force-reinstall -U "git+https://github.com/IndustryEssentials/ymir.git/@dev#egg=ymir-exc&subdirectory=docker_executor/sample_executor/ymir_exc"; \
    else \
        pip install ymir-exc; \
    fi

# Copy file from host to docker and install requirements
ADD ./det-yolov5-tmi /app
RUN mkdir /img-man && mv /app/*-template.yaml /img-man/ \
    && pip install -r /app/requirements.txt

# Download pretrained weight and font file
RUN cd /app && bash data/scripts/download_weights.sh \
    && mkdir -p /root/.config/Ultralytics \
    && wget https://ultralytics.com/assets/Arial.ttf -O /root/.config/Ultralytics/Arial.ttf

# Make PYTHONPATH find local package
ENV PYTHONPATH=.

WORKDIR /app
RUN echo "python3 /app/start.py" > /usr/bin/start.sh
CMD bash /usr/bin/start.sh
