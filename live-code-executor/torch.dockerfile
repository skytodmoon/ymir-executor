ARG PYTORCH="1.8.0"
ARG CUDA="11.1"
ARG CUDNN="8"

# cuda11.1 + pytorch 1.9.0 not work!!!
FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-runtime

ARG SERVER_MODE=dev
ARG OPENCV="4.1.2.30"
ARG NUMPY="1.20.0"
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"
ENV LANG=C.UTF-8

# install linux package
RUN apt-get update && apt-get install -y git curl wget zip gcc \
    libglib2.0-0 libgl1-mesa-glx libsm6 libxext6 libxrender-dev \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple

# Install python package
RUN pip3 install -U pip && \
    pip3 install loguru opencv-python==${OPENCV} numpy==${NUMPY}

# install ymir-exc sdk
RUN if [ "${SERVER_MODE}" = "dev" ]; then \
    pip3 install "git+https://github.com/IndustryEssentials/ymir.git/@dev#egg=ymir-exc&subdirectory=docker_executor/sample_executor/ymir_exc"; \
  else \
    pip3 install ymir-exc; \
  fi

# copy template training/mining/infer config file
RUN mkdir -p /img-man
COPY img-man/*.yaml /img-man/
COPY start.sh /usr/bin

RUN mkdir -p /root/.config/Ultralytics \
&& wget https://ultralytics.com/assets/Arial.ttf -O /root/.config/Ultralytics/Arial.ttf \
&& wget https://ultralytics.com/assets/Arial.Unicode.ttf -O /root/.config/Ultralytics/Arial.Unicode.ttf

WORKDIR /workspace
COPY ymir_start.py /workspace/ymir_start.py

# set up python path
ENV PYTHONPATH=.

CMD bash /usr/bin/start.sh
