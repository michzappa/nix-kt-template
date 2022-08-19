{
  description = "a nix-enabled project template for kotlin applications";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    gradle2nix.url = "github:michzappa/gradle2nix";
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, ... }@inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs { inherit system; });
        buildGradle = pkgs.callPackage ./gradle-env.nix { };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            gradle
            inputs.gradle2nix.packages.${system}.default
            kotlin
            kotlin-language-server
            ktlint
          ];
        };

        packages.default = buildGradle {
          envSpec = ./gradle-env.json;
          gradleFlags = [ "installDist" ];
          installPhase = ''
            mkdir -p $out
            cp -r app/build/install/app/* $out

            # for `nix run`, with an appropriately configured project
            # this should be unnecessary
            ln -s $out/bin/app $out/bin/nix-kt-template
          '';
          pname = "nix-kt-template";
          src = ./.;
        };
      });
}
