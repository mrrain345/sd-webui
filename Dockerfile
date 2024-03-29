FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBIAN_PRIORITY=critical
ARG PIP_PREFER_BINARY=1

WORKDIR /app

# Install dependencies
RUN apt-get update
RUN apt-get install -y make build-essential nano \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev git wget curl llvm libncursesw5-dev \
  xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev libpng-dev libjpeg-dev

# Install Python 3.10
RUN apt-get install --yes --quiet --no-install-recommends \
  python3.10 \
  python3.10-dev \
  python3.10-distutils \
  python3.10-lib2to3 \
  python3.10-gdbm \
  python3.10-tk \
  python3.10-venv \
  pip

# Clone the repository
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
WORKDIR /app/stable-diffusion-webui

# Set symlinks
RUN mv models models_default && \
  ln -s /data/models models && \
  rm -rf extensions && \
  ln -s /data/extensions extensions && \
  ln -s /data/repositories repositories && \
  ln -s /data/output output

# Set the environment variables
ENV install_dir /app
ENV venv_dir /data/venv

# Copy files
ADD entrypoint.sh extensions.txt /app/

EXPOSE 7860
VOLUME /data

# Run the application
ENTRYPOINT /app/entrypoint.sh