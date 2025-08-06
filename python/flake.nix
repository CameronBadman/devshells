{
  description = "Python development profile with enhanced nvim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    # Import your base nvim flake 
    nvim-flake.url = "github:CameronBadman/nvim-flake";  # Your actual repo
    nixvim.follows = "nvim-flake/nixvim";
  };

  outputs = { nixpkgs, nixvim, flake-parts, nvim-flake, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      
      perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
        
        # Main package - enhanced nvim that gets added to profile
        packages.default = let
          pythonEnhancedNvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit pkgs;
            module = {
              imports = [
                nvim-flake.nixvimModule
              ];
              
              # Python extensions
              plugins.lsp.servers = lib.mkMerge [
                {
                  pyright.enable = true;
                  ruff_lsp.enable = true;
                }
              ];
              
              plugins.cmp.settings.sources = lib.mkAfter [
                { name = "nvim_lsp_signature_help"; priority = 900; }
              ];
              
              plugins.treesitter.grammarPackages = lib.mkAfter 
                (with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
                  python
                  toml
                ]);
                
              keymaps = lib.mkAfter [
                {
                  mode = "n";
                  key = "<leader>pr";
                  action = ":!python %<CR>";
                  options.desc = "Run Python file";
                }
                {
                  mode = "n";
                  key = "<leader>pt";
                  action = ":!pytest<CR>";
                  options.desc = "Run pytest";
                }
              ];
            };
          };
        in pkgs.writeShellScriptBin "nvim-python" ''
          export NVIM_PROFILE="python"
          exec ${pythonEnhancedNvim}/bin/nvim "$@"
        '';
        
        # Development shell for working IN the profile
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3Packages.pip
            python3Packages.poetry
            pyright
            ruff
            black
            mypy
            self'.packages.default
          ];
          
          shellHook = ''
            echo "🐍 Python profile loaded!"
            echo "Use 'nvim-python' for enhanced Python nvim"
          '';
        };
        
        # Regular nvim package (for compatibility)
        packages.nvim = self'.packages.default;
      };
    };
}
