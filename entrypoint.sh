#/bin/sh

# Create an virtual environment if it does not exist and install the required dependencies
if [ ! -d "/data/venv" ]; then
  python3.10 -m venv /data/venv
  . /data/venv/bin/activate

  pip3 install basicsr insightface xformers -r /app/stable-diffusion-webui/requirements_versions.txt
fi

# Activate the virtual environment
. /data/venv/bin/activate

# Copy the default models directory to the data directory
if [ ! -d "/data/models" ]; then
  cp -r /app/stable-diffusion-webui/models_default /data/models
fi

# Create the repositiories directory if it does not exist
if [ ! -d "/data/repositories" ]; then
  mkdir /data/repositories
fi

# Create the output directory if it does not exist
if [ ! -d "/data/output" ]; then
  mkdir /data/output
fi

# Install extensions if they are not installed
EXTENSIONS=$(cat /app/extensions.txt)
for EXT_URL in $EXTENSIONS; do
  EXT_NAME=$(basename "$EXT_URL" .git)
  if [ ! -d "/data/extensions/$EXT_NAME" ]; then
    echo "Installing extension $EXT_NAME from $EXT_URL"
    git clone $EXT_URL /data/extensions/$EXT_NAME
    if [ -f "/data/extensions/$EXT_NAME/requirements.txt" ]; then
      pip3 install -r /data/extensions/$EXT_NAME/requirements.txt
    fi
  fi
done

# Launch the webui
python3.10 /app/stable-diffusion-webui/launch.py --listen --xformers --enable-insecure-extension-access