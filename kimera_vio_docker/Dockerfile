# Use an official Python runtime as a parent image
FROM ubuntu:18.04

MAINTAINER Allen Cutinha "allencutinha@outlook.com"

# To avoid tzdata asking for geographic location...
ENV DEBIAN_FRONTEND noninteractive

# Change these according to your organisation proxies
ENV HTTP_PROXY=http://10.102.160.2:8080
ENV HTTPS_PROXY=http://10.102.160.2:8080
ENV http_proxy=http://10.102.160.2:8080
ENV https_proxy=http://10.102.160.2:8080

# Set the working directory to /root
ENV DIRPATH /root
WORKDIR $DIRPATH

#Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && apt-get install -y git cmake

# Install xvfb to provide a display to container for GUI related testing.
RUN apt-get update && apt-get install -y xvfb

# Install GTSAM
RUN apt-get update && apt-get install -y libboost-all-dev
ADD https://api.github.com/repos/borglab/gtsam/git/refs/heads/master version.json
RUN git clone https://github.com/borglab/gtsam.git
RUN cd gtsam && \
    git checkout 4.1 && \
    git fetch && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DGTSAM_BUILD_TESTS=OFF -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF -DCMAKE_BUILD_TYPE=Release -DGTSAM_BUILD_UNSTABLE=ON -DGTSAM_TANGENT_PREINTEGRATION=OFF .. && \
    make -j$(nproc) install

# Install OpenCV for Ubuntu 18.04
RUN apt-get update && apt-get install -y \
      build-essential cmake unzip pkg-config \
      libjpeg-dev libpng-dev libtiff-dev \
      libvtk6-dev \
      libgtk-3-dev \
      libatlas-base-dev gfortran

RUN git clone https://github.com/opencv/opencv.git
RUN cd opencv && \
      git checkout tags/3.3.1 && \
      mkdir build

RUN git clone https://github.com/opencv/opencv_contrib.git
RUN cd opencv_contrib && \
      git checkout tags/3.3.1

RUN cd opencv/build && \
      cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -D BUILD_opencv_python=OFF \
      -D BUILD_opencv_python2=OFF \
      -D BUILD_opencv_python3=OFF \
      -DOPENCV_EXTRA_MODULES_PATH=$DIRPATH/opencv_contrib/modules .. && \
      make -j$(nproc) install

# Install Open_GV
RUN git clone https://github.com/laurentkneip/opengv
RUN cd opengv && \
      mkdir build
RUN cd opengv/build && \
      cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DEIGEN_INCLUDE_DIRS=$DIRPATH/gtsam/gtsam/3rdparty/Eigen \
      -DEIGEN_INCLUDE_DIR=$DIRPATH/gtsam/gtsam/3rdparty/Eigen .. && \
      make -j$(nproc) install

# Install DBoW2
RUN git clone https://github.com/dorian3d/DBoW2.git
RUN cd DBoW2 && \
      mkdir build && \
      cd build && \
      cmake .. && \
      make -j$(nproc) install

# Install RobustPGO
ADD https://api.github.com/repos/MIT-SPARK/Kimera-RPGO/git/refs/heads/master version.json
RUN git clone https://github.com/MIT-SPARK/Kimera-RPGO.git

RUN cd Kimera-RPGO && \
      mkdir build && \
      cd build && \
      cmake .. && \
      make -j$(nproc)

## [Optional] Install Kimera-VIO-Evaluation from PyPI
RUN apt-get update && \
    apt-get install software-properties-common -y

# Install evo-1 for evaluation
# Hack to avoid Docker's cache when evo-1 master branch is updated.
ADD https://api.github.com/repos/ToniRV/evo-1/git/refs/heads/master version.json
RUN git clone https://github.com/ToniRV/evo-1.git

# Install spark_vio_evaluation
# RUN pip3 install ipython prompt_toolkit
# Hack to avoid Docker's cache when spark_vio_evaluation master branch is updated.
ADD https://api.github.com/repos/ToniRV/Kimera-VIO-Evaluation/git/refs/heads/master version.json
RUN git clone https://github.com/ToniRV/Kimera-VIO-Evaluation.git


# Add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 600 ~/.ssh/id_rsa

# Make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# Install glog, gflags
RUN apt-get update && apt-get install -y libgflags2.2 libgflags-dev libgoogle-glog0v5 libgoogle-glog-dev

# Install Kimera-VIO
RUN git clone https://github.com/MIT-SPARK/Kimera-VIO.git
RUN cd Kimera-VIO && mkdir build && cd build && cmake .. && make -j$(nproc)

# Download and extract EuRoC dataset.
RUN apt-get update && apt-get install -y wget
RUN wget http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/vicon_room1/V1_01_easy/V1_01_easy.zip
RUN mkdir -p $DIRPATH/euroc && unzip V1_01_easy.zip -d $DIRPATH/euroc




ENV CONDA_DIR /opt/conda
#FROM continuumio/miniconda3


RUN apt-get update && apt-get install -y curl && \
   wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
   /bin/bash ~/miniconda.sh -b -p /opt/conda && \
   rm -f ~/miniconda.sh && \
   ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
   echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
   echo "conda activate base" >> ~/.bashrc && \
   /opt/conda/bin/conda clean -afy

ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda init

RUN conda update -y conda

RUN conda create -n py35 python=3.5 -y
RUN echo "source activate py35" > ~/.bashrc
ENV PATH /opt/conda/envs/py35/bin:$PATH


RUN conda install tk
RUN /opt/conda/envs/py35/bin/pip install PyQt5==5.14
RUN cd /root/evo-1 && /opt/conda/envs/py35/bin/pip install .

# RUN cd /root/Kimera-VIO-Evaluation && /opt/conda/envs/py35/bin/pip install .

# Yamelize euroc dataset
RUN bash $DIRPATH/Kimera-VIO/scripts/euroc/yamelize.bash -p $DIRPATH/euroc

RUN apt install eog -y

#CMD xvfb-run $DIRPATH/Kimera-VIO/scripts/stereoVIOEuroc.bash -p $DIRPATH/euroc -r
# CMD $DIRPATH/Kimera-VIO/scripts/stereoVIOEuroc.bash -p $DIRPATH/euroc -r
