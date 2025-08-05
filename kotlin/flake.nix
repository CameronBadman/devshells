{
  description = "Kotlin development environment profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
      in {
        packages.default = pkgs.buildEnv {
          name = "kotlin-dev-profile";
          paths = with pkgs; [
            kotlin
            gradle
            maven
            openjdk17
            kotlin-language-server
            git
          ];
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            kotlin
            gradle
            maven
            openjdk17
            kotlin-language-server
            git
            curl
            unzip
          ];
          
          JAVA_HOME = "${pkgs.openjdk17}/lib/openjdk";
          GRADLE_USER_HOME = ".gradle";
        };
      });
}
