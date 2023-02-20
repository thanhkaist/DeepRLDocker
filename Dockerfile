FROM nvidia/cuda:10.0-base

# Solve GPG error
RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list
# Install neccessary packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated --no-install-recommends \
    build-essential apt-utils cmake git curl vim ca-certificates \
    libjpeg-dev libpng-dev \
    libgtk3.0 libsm6 cmake ffmpeg pkg-config \
    qtbase5-dev libqt5opengl5-dev libassimp-dev \
    libboost-python-dev libtinyxml-dev bash \
    wget unzip libosmesa6-dev software-properties-common \
    libopenmpi-dev libglew-dev openssh-server \
    libosmesa6-dev libgl1-mesa-glx libgl1-mesa-dev patchelf libglfw3 tmux

RUN rm -rf /var/lib/apt/lists/*

# Create user
ARG UID
RUN useradd -u $UID --create-home user  && echo "user:123456" | chpasswd && adduser user sudo
USER user
WORKDIR /home/user

RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH /home/user/miniconda3/bin:$PATH

RUN mkdir -p .mujoco \
    && wget https://www.roboti.us/download/mjpro150_linux.zip -O mujoco.zip \
    && unzip mujoco.zip -d .mujoco \
    && rm mujoco.zip
RUN wget https://www.roboti.us/download/mujoco200_linux.zip -O mujoco.zip \
    && unzip mujoco.zip -d .mujoco \
    && rm mujoco.zip

RUN wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O mujoco.tar.gz \
    && tar -xf mujoco.tar.gz -C .mujoco \
    && rm mujoco.tar.gz

RUN conda init bash
RUN echo set-option -g default-shell /bin/bash >> ~/.tmux.conf
RUN echo set -g mouse on >> ~/.tmux.conf

# Make sure you have a license, otherwise comment this line out
# Of course you then cannot use Mujoco and DM Control, but Roboschool is still available
COPY ./mjkey.txt .mujoco/mjkey.txt

ENV LD_LIBRARY_PATH /home/user/.mujoco/mjpro150/bin:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH /home/user/.mujoco/mjpro200_linux/bin:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH /home/user/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

RUN conda install -y -c anaconda python=3.10
RUN conda install mpi4py
# install pytorch
RUN conda install pytorch==1.11.0 torchvision==0.12.0 torchaudio==0.11.0 cudatoolkit=10.2 -c pytorch

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
RUN pip install glfw Cython imageio lockfile
RUN pip install -U 'mujoco-py<2.2,>=2.1'

WORKDIR /home/user/
