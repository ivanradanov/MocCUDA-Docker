###########################################################
#
# Docker image for MocCUDA artifact evaluation.
#
###########################################################

FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
ARG DEBIAN_FRONTEND=noninteractive
ARG GID
ARG UID
RUN echo "Group ID: $GID"
RUN echo "User ID: $UID"

# Essential packages
RUN apt-get update
RUN apt-get install apt-utils -y
RUN apt-get -y install tzdata --assume-yes



RUN apt-get install git cmake gcc g++ ninja-build python3 build-essential -y

WORKDIR /root
RUN git clone https://gitlab.com/domke/MocCUDA && cd MocCUDA && git checkout c9647a52
WORKDIR MocCUDA
RUN git submodule update --init --recursive


RUN apt-get install python libkqueue-dev libblocksruntime-dev -y
COPY ./scripts/host.env ./scripts/
RUN bash ./scripts/00*
COPY ./scripts/01_cuda.sh ./scripts/
RUN bash ./scripts/01*
RUN apt-get install python3-venv -y
COPY ./scripts/02_python.sh ./scripts/
RUN bash ./scripts/02*

WORKDIR /root
RUN apt-get install wget -y
RUN wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
RUN apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
#RUN sh -c 'echo deb apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list' && apt-key adv --keyserver keyserver.ubuntu.com --recv ACFA9FC57E6C5DBE && apt update && apt-cache search intel-mkl-64bit
RUN wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list
RUN apt-get update

WORKDIR MocCUDA

RUN apt-get install intel-mkl-2020.4-912 -y
RUN apt-get install python3-yaml python3-setuptools python-cffi python-typing -y --assume-yes
RUN apt-get install python3-pip -y
RUN pip3 install mkl-devel
RUN apt-get install libopenmpi-dev -y
COPY ./scripts/03_pytorch.sh ./scripts/
RUN bash ./scripts/03*

COPY ./scripts/04_horovod.sh ./scripts/
RUN bash ./scripts/04*

COPY ./scripts/05_benchmarker.sh ./scripts/
RUN bash ./scripts/05*
RUN bash ./scripts/07*
RUN bash ./scripts/08*
