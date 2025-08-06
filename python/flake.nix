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
        
        # Python development tools
        pythonTools = with pkgs; [
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
        
        # Create Neovim profile package
        nvim-python-profile = pkgs.stdenv.mkDerivation {
          name = "nvim-python-profile";
          src = ./python;
          
          installPhase = ''
            mkdir -p $out/share/nvim-profiles/python
            cp init.lua $out/share/nvim-profiles/python/init.lua
            echo "Python Neovim profile installed"
          '';
        };
        
      in {
        packages = {
          default = pkgs.symlinkJoin {
            name = "python-dev-profile";
            paths = pythonTools ++ [ nvim-python-profile ];
          };
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = pythonTools;
          
          shellHook = ''
            echo "🐍 Python development environment loaded!"
            echo "📦 Available tools: python3, pyright, black, ruff, pytest, mypy"
            
            # Set up Python environment
            export PYTHONPATH="$PWD:$PYTHONPATH"
          '';
        };
      });
}
