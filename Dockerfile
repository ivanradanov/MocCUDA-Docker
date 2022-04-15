###########################################################
#
# Docker image for MocCUDA artifact evaluation.
#
###########################################################

FROM nvidia/cuda:11.6.2-cudnn7-devel-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG GID
ARG UID
RUN echo "Group ID: $GID"
RUN echo "User ID: $UID"

# Essential packages
RUN apt-get update
RUN apt-get install apt-utils
RUN apt-get -y install tzdata --assume-yes



RUN apt-get install git cmake gcc g++ ninja-build python3 build-essential -y

WORKDIR /root
RUN git clone https://gitlab.com/domke/MocCUDA && cd MocCUDA && git checkout c9647a52
WORKDIR MocCUDA
RUN git submodule update --init --recursive


RUN apt-get install python2 libkqueue-dev libblocksruntime-dev -y
COPY ./scripts/host.env ./scripts/
#COPY ./scripts/00* ./scripts/
RUN bash ./scripts/00*
COPY ./scripts/01* ./scripts/
RUN bash ./scripts/01*
RUN apt-get install python3.8-venv -y
COPY ./scripts/02* ./scripts/
RUN bash ./scripts/02*
RUN apt-get install intel-mkl libmkl-dev python3-yaml python3-setuptools python-cffi python-typing -y --assume-yes
RUN apt-get install python3-pip -y
RUN pip3 install mkl-devel
COPY ./scripts/03* ./scripts/
RUN bash ./scripts/03*
RUN bash ./scripts/04*
RUN bash ./scripts/05*
RUN bash ./scripts/07*
RUN bash ./scripts/08*
