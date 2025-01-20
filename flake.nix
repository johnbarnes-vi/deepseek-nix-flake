{
  description = "Minimal PyTorch development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          torch-bin
        ]);

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pythonEnv ];

          shellHook = ''
            export PYTHONPATH="$PWD:$PYTHONPATH"
            echo "Python environment ready"
            ${pythonEnv}/bin/python -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available()); print('CUDA version:', torch.version.cuda if torch.cuda.is_available() else 'N/A')"
          '';
        };
      });
}