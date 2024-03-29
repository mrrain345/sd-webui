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

# Install extensions
# RUN git clone https://github.com/d8ahazard/sd_dreambooth_extension.git extensions/sd_dreambooth_extension
# RUN git clone https://github.com/Mikubill/sd-webui-controlnet extensions/sd-webui-controlnet
# # TODO: download controlnet models
# RUN git clone https://github.com/zanllp/sd-webui-infinite-image-browsing extensions/sd-webui-infinite-image-browsing
# RUN git clone https://github.com/alemelis/sd-webui-ar extensions/sd-webui-ar
# RUN git clone https://github.com/zixaphir/Stable-Diffusion-Webui-Civitai-Helper extensions/sd-webui-civitai-helper
# RUN git clone https://github.com/Bing-su/adetailer extensions/sd-webui-adetailer
# RUN git clone https://github.com/hako-mikan/sd-webui-regional-prompter extensions/sd-webui-regional-prompter
# RUN git clone https://github.com/fkunn1326/openpose-editor extensions/sd-webui-openpose-editor
# RUN git clone https://github.com/deforum-art/sd-webui-deforum extensions/sd-webui-deforum
# RUN git clone https://github.com/lobehub/sd-webui-lobe-theme extensions/sd-webui-lobe-theme
# RUN git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser extensions/stable-diffusion-webui-images-browser
# RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-rembg extensions/stable-diffusion-webui-rembg
# RUN git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete extensions/a1111-sd-webui-tagcomplete

# Copy files
ADD entrypoint.sh extensions.txt /app/

EXPOSE 7860 5173
VOLUME /data

# Run the application
ENTRYPOINT /app/entrypoint.sh

# CMD python3.10 -m venv $venv_dir && \
#   . $venv_dir/bin/activate && \
#   pip install xformers python-dotenv lxml fvcore svglib handrefinerportable depth_anything dsine basicsr && \
#   python3.10 launch.py