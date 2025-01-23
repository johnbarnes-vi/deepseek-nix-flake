{
  description = "NVIDIA PyTorch Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        # Hardcoded project name
        project-name = "deepseek";

        pytorch-launch = pkgs.writeShellScriptBin "pytorch" ''
          STACK_SIZE=67108864
          
          # Create persistent volumes with project-specific names
          docker volume create ${project-name}-pytorch-packages
          docker volume create ${project-name}-pytorch-cache
          
          # Parse arguments for custom workspace mounting
          WORKSPACE_MOUNT=""
          if [ -n "$1" ]; then
            WORKSPACE_MOUNT="-v $PWD/$1:/workspace/mounted"
          fi

          docker run \
            --device=nvidia.com/gpu=all \
            --ipc=host \
            --ulimit memlock=-1 \
            --ulimit stack=$STACK_SIZE \
            -v ${project-name}-pytorch-packages:/usr/local/lib/python3.12/dist-packages \
            -v ${project-name}-pytorch-cache:/root/.cache \
            -it \
            --rm \
            $WORKSPACE_MOUNT \
            nvcr.io/nvidia/pytorch:24.12-py3
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pytorch-launch
          ];

          shellHook = ''
            echo "NVIDIA PyTorch Development Environment"
            echo "--------------------------------------"
            echo "Commands:"
            echo "  pytorch                  - Launch PyTorch container"
            echo "  pytorch <directory>      - Launch PyTorch container with <directory> mounted to /workspace/mounted"
            echo ""
            echo "Persistent Volumes:"
            echo "  ${project-name}-pytorch-packages  - Persists installed Python packages in /usr/local/lib/python3.12/dist-packages"
            echo "  ${project-name}-pytorch-cache    - Persists pip and compiler caches in /root/.cache"
            echo ""
            echo "Example:"
            echo "  pytorch data            - Mounts ./data to /workspace/mounted in container"
            echo ""
            echo "Note: Flash Attention and other compiled packages will persist between sessions"
            echo ""
            echo "To clear persistent packages and start fresh:"
            echo "  docker volume rm ${project-name}-pytorch-packages ${project-name}-pytorch-cache"
          '';
        };
      }
    );
}