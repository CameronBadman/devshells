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
        
      in {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            name = "python-dev-profile";
            src = ./.;
            
            installPhase = ''
              # Create output directories
              mkdir -p $out/bin $out/share/nvim-profiles/python
              
              # Install Python development tools
              ${builtins.concatStringsSep "\n" (map (tool: ''
                if [ -d "${tool}/bin" ]; then
                  cp -r ${tool}/bin/* $out/bin/ 2>/dev/null || true
                fi
              '') pythonTools)}
              
              # Install Neovim profile
              cp python/init.lua $out/share/nvim-profiles/python/init.lua
              
              echo "Python development profile with Neovim integration installed"
            '';
            
            buildInputs = pythonTools;
          };
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = pythonTools ++ [
            pkgs.curl
            pkgs.python3Packages.virtualenv
          ];
          
          shellHook = ''
            echo "🐍 Python development environment loaded!"
            echo "📦 Available tools: python3, pyright, black, ruff, pytest, mypy"
            echo "📝 Neovim profile will be available after 'nix profile install'"
            
            # Set up Python environment
            export PYTHONPATH="$PWD:$PYTHONPATH"
          '';
        };
      });
}
