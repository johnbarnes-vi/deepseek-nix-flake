# DeepSeek Development Environment

This repository contains a Nix flake configuration for running DeepSeek models using NVIDIA's official PyTorch container.

## Structure

The development environment uses NVIDIA's PyTorch container with persistent volumes for package management and caching:

```nix
pytorch-launch = pkgs.writeShellScriptBin "pytorch" ''
  # Launch PyTorch container with persistent volumes and GPU support
'';
```

The flake provides:
- A convenient `pytorch` command for launching the container
- Persistent volumes for installed packages and cache
- Automatic GPU device mapping
- Configurable workspace mounting

### Why Docker-based?

This approach offers several advantages:
- Uses NVIDIA's officially optimized PyTorch container
- Persistent package installation between sessions
- Consistent CUDA toolkit and driver compatibility
- Isolated environment for deep learning development

## Usage

1. Clone this repository
2. Ensure you have Docker and NVIDIA Container Toolkit installed
3. Enter the development environment:
```bash
direnv allow  # If using direnv
# or
nix develop   # If using nix directly
```

Once in the development shell, you can:

- Launch basic PyTorch container:
```bash
pytorch
```

- Mount a workspace directory:
```bash
pytorch data  # Mounts ./data to /workspace/mounted
```

### Persistent Volumes

The environment creates two persistent Docker volumes:
- `deepseek-pytorch-packages`: Stores installed Python packages
- `deepseek-pytorch-cache`: Stores pip and compiler caches

To clear these volumes and start fresh:
```bash
docker volume rm deepseek-pytorch-packages deepseek-pytorch-cache
```

## Dependencies

- NixOS or Nix with flakes enabled
- Docker with NVIDIA Container Toolkit
- NVIDIA GPU with compatible drivers
- direnv (optional but recommended)

## Model Setup

1. Install Git LFS if you haven't already:

2. Clone the DeepSeek model of your choice from huggingface:
```bash
git lfs clone https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B
```

The model files should be placed in the `src/DeepSeek-R1-Distill-Qwen-7B` directory.

## Running DeepSeek Models

The repository includes an `inference.py` script for running DeepSeek models. After entering the PyTorch container, you can run:

```bash
python /workspace/mounted/inference.py
```

This will load the DeepSeek model and start an interactive chat session.