#FROM nvidia/cuda:11.0.3-devel-ubuntu18.04
#FROM ubuntu2004
#FROM nvidia/cuda:11.1.1-cudnn8-runtime-ubuntu20.04
FROM registry.cn-zhangjiakou.aliyuncs.com/com_futuremake/nvidia-ubuntu2004:1.0
#ARG PIP_SOURCE=https://pypi.mirrors.ustc.edu.cn/simple
WORKDIR /darknet
RUN apt-get update
RUN apt install -y software-properties-common wget
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install --assume-yes apt-utils
RUN apt install build-essential -y
RUN apt-get update
RUN apt install libterm-readkey-perl -y
RUN apt install -y python3.8 python3-distutils
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137
RUN rm /usr/bin/python3
RUN ln -s /usr/bin/python3.8 /usr/bin/python3
RUN python3 get-pip.py
RUN pip3 install -i ${PIP_SOURCE} mxnet-cu111==1.9.1 numpy opencv-python pyyaml watchdog tensorboardX six
RUN echo '\ndeb https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse\ndeb https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse\ndeb https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse\ndeb https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse\n' >> /etc/apt/sources.list
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y libopencv-dev
COPY . /darknet
RUN cp /darknet/make_train_test_darknet.sh /usr/bin/start.sh
RUN mkdir /img-man && cp /darknet/training-template.yaml /img-man/training-template.yaml
RUN make -j
CMD bash /usr/bin/start.sh
