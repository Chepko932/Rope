#!/bin/bash

# Step 0: Display warnings and instructions
echo "WARNING: This auto installer requires Python 3.10.11 or 3.10.13+"
echo "For NVIDIA use, CUDA framework from NVIDIA website (version 11.8.0 suggested) and Miniconda are required."
echo "Miniconda installation tutorial: https://youtu.be/ULAVtKBOKXE"
echo "Press any key to continue..."
read -n 1 -s

# Step 1: Install necessary Python packages and Git LFS
pip install requests tqdm gdown
git lfs install
python3 -m ensurepip --upgrade
pip install --upgrade setuptools
pip install --upgrade pip wheel

# Step 2: Check if repository 'Rope-Origin' already exists
REPO_DIR="Rope-Origin"
if [ -d "$REPO_DIR" ]; then
    echo "The repository '$REPO_DIR' already exists."
else
    echo "Cloning repository..."
    git clone https://github.com/Chepko932/Rope
fi

# Navigate to the Rope repository and clean up
cd Rope || exit
rm Rope.bat
cd ..
mv Rope Rope-Origin

# Step 3: Download models using gdown
echo "Downloading models..."
gdown https://drive.google.com/uc?id=1HEv-JIXW9QbCJ6kdTRgiOM7qXK1PnaDD -O ropemodels.zip

echo "*********** INSTRUCTIONS ************"
echo "***  1. Download completed         ***"
echo "***  2. Press any key to start     ***"
echo "***     extraction...              ***"
echo "*************************************"
read -n 1 -s

# Step 4: Extracting models
zip_file="ropemodels.zip"
extract_to="Rope-Origin/models"

if [ ! -d "$extract_to" ]; then
    mkdir -p "$extract_to"
fi

unzip "$zip_file" -d "$extract_to"
echo "Extraction completed successfully."

# Step 5: Change directory to Rope-Origin
cd Rope-Origin || exit

# Step 6: Retrieve CUDA version
CUDA_VERSION=$(nvcc --version | grep -oP 'release \K[0-9.]+')
if [ -z "$CUDA_VERSION" ]; then
    echo "Error: CUDA version not found. Make sure CUDA Toolkit is installed and nvcc is accessible."
    exit 1
fi
echo "Detected CUDA version: $CUDA_VERSION"

# Step 7: Create virtual environment
conda create -n rope-origin python=3.10.13 -y

# Step 8: Activate virtual environment
source ~/miniconda3/bin/activate rope-origin

# Step 9: Install CUDA Toolkit using conda
conda install cuda-runtime=11.8.0 cudnn=8.9.2.26 -c conda-forge gputil=1.4.0 -y

# Step 10: Install dependencies with pip
python3 -m pip install -r requirements.txt

echo "Virtual environment set up successfully."

# Step 11: Clean up and finish
cd ..
echo "Installation process completed."
conda deactivate
