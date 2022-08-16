{
  description =
    "https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours";

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
          pname = "nix-kt-template";

          envSpec = ./gradle-env.json;

          src = ./.;

          gradleFlags = [ "installDist" ];

          installPhase = ''
            mkdir -p $out
            cp -r app/build/install/app/* $out
            # for `nix run`, which wants an executable the same as the project name
            ln -s $out/bin/app $out/bin/nix-kt-template
          '';
        };

      });
}
