#!/bin/bash
set -e
eval "$(conda shell.bash hook)"
conda activate base
conda config --set channel_priority false
conda env create -f environment.yml
conda activate graphml-venv
conda install python=3.8.5
conda install -c conda-forge jupyterlab

case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    echo "LINUX"
    conda install pytorch==1.7.0 torchvision cudatoolkit -c pytorch
    ;;
  darwin*)
    echo "OSX"
    conda install pytorch==1.7.0 torchvision -c pytorch
    ;;
  *)
      exit 1
    ;;
esac
conda info --envs
TORCH=$(python -c "import torch; print(torch.__version__)")
CUDA=$(python -c "import torch; print(torch.version.cuda)")

# Checks CUDA variant and installs DGL and Sets CUDA variable
if [ "$CUDA" = "None" ]; then
    CUDA="cpu";
    conda install -c dglteam dgl;
elif [ "$CUDA" = "10.1" ]; then
    CUDA="cu101";
    conda install -c dglteam dgl-cuda10.1;
elif [ "$CUDA" = "10.0" ]; then
    CUDA="cu100";
    conda install -c dglteam dgl-cuda10.0;
elif [ "$CUDA" = "11.0" ]; then
    CUDA="cu110";
    conda install -c dglteam dgl-cuda11.0;
fi

# Below is to ensure we have the correct version of Pytorch Installed
pip install torch-scatter -f https://pytorch-geometric.com/whl/torch-${TORCH}+${CUDA}.html
pip install torch-sparse -f https://pytorch-geometric.com/whl/torch-${TORCH}+${CUDA}.html
pip install torch-cluster -f https://pytorch-geometric.com/whl/torch-${TORCH}+${CUDA}.html
pip install torch-spline-conv -f https://pytorch-geometric.com/whl/torch-${TORCH}+${CUDA}.html
pip install torch-geometric > /dev/null

echo "Installation Successful"
echo "Activate Conda Environment with: conda activate graphml-venv"

