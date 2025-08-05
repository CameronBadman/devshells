{
  description = "Python development environment profile";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Install script for Neovim profile
        install-python-profile = pkgs.writeShellScriptBin "install-python-profile" ''
          #!/usr/bin/env bash
          set -e
          
          NVIM_PROFILES_DIR="$HOME/.config/nvim-profiles"
          PYTHON_PROFILE_DIR="$NVIM_PROFILES_DIR/python"
          
          echo "🐍 Installing Python Neovim profile..."
          
          # Create profiles directory if it doesn't exist
          mkdir -p "$NVIM_PROFILES_DIR"
          
          # Remove existing python profile if it exists
          rm -rf "$PYTHON_PROFILE_DIR"
          
          # Copy Python profile to nvim profiles directory
          cp -r "${./python}" "$PYTHON_PROFILE_DIR"
          
          echo "✅ Python Neovim profile installed to: $PYTHON_PROFILE_DIR"
          echo "🚀 Restart Neovim to load the Python profile"
        '';
        
      in {
        packages = {
          default = pkgs.buildEnv {
            name = "python-dev-profile";
            paths = with pkgs; [
              python3
              pyright
              python3Packages.python-lsp-server
              python3Packages.python-lsp-black
              python3Packages.python-lsp-ruff
              black
              ruff
              python3Packages.flake8
              python3Packages.mypy
              python3Packages.pytest
              python3Packages.pip
              git
            ];
          };
          
          # Install script for Neovim profile
          install-profile = install-python-profile;
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            pyright
            python3Packages.python-lsp-server
            python3Packages.python-lsp-black
            python3Packages.python-lsp-ruff
            black
            ruff
            python3Packages.flake8
            python3Packages.mypy
            python3Packages.pytest
            python3Packages.pip
            python3Packages.virtualenv
            git
            curl
            
            # Install script
            install-python-profile
          ];
          
          shellHook = ''
            echo "🐍 Python development environment loaded!"
            echo "📦 Available tools: python3, pyright, black, ruff, pytest, mypy"
            echo "📝 Run 'install-python-profile' to install Neovim profile"
            echo "🚀 Then restart Neovim to get Python LSP support"
            
            # Set up Python environment
            export PYTHONPATH="$PWD:$PYTHONPATH"
          '';
        };
      });
}
