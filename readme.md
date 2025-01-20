# PyTorch Development Environment

This repository contains a minimal Nix flake configuration for PyTorch development on NixOS.

## Structure

The development environment is intentionally minimal:

```nix
pythonEnv = pkgs.python311.withPackages (ps: with ps; [
  torch-bin
]);
```

The flake only requires:
- `allowUnfree = true` for NVIDIA packages
- Python environment with torch-bin

The shellHook provides immediate verification of the PyTorch installation and CUDA support:
```nix
shellHook = ''
  export PYTHONPATH="$PWD:$PYTHONPATH"
  echo "Python environment ready"
  ${pythonEnv}/bin/python -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available()); print('CUDA version:', torch.version.cuda if torch.cuda.is_available() else 'N/A')"
'';
```

### Why It's Minimal

Unlike the CUDA C/C++ development environment, this flake doesn't need explicit CUDA toolkit packages because:
- `torch-bin` is pre-compiled with CUDA support
- It uses the system's NVIDIA drivers and CUDA runtime
- No compilation of CUDA code is needed during development

## Usage

1. Clone this repository
2. Ensure your NixOS configuration has proper NVIDIA support
3. Enter the development environment:
```bash
direnv allow  # If using direnv
# or
nix develop   # If using nix directly
```

The environment will automatically print PyTorch version and CUDA availability information when you enter it.

## Dependencies

- NixOS with proper NVIDIA driver configuration
- Flakes enabled in Nix
- direnv (optional but recommended)