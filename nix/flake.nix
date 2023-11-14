# nix/flake.nix
#
# This file packages dry-wit as a Nix flake.
#
# Copyright (C) 2008-today rydnr's dry-wit
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Dry-wit bash framework";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };
  outputs = inputs:
    with inputs;
    let
      defaultSystems = flake-utils.lib.defaultSystems;
      supportedSystems = if builtins.elem "armv6l-linux" defaultSystems then
        defaultSystems
      else
        defaultSystems ++ [ "armv6l-linux" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        org = "rydnr";
        repo = "dry-wit";
        pname = "${org}-${repo}";
        version = "3.0.4";
        pkgs = import nixos { inherit system; };
        description = "Dry-wit bash framework";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        dry-wit-for = { sh, sh-name }:
          pkgs.stdenv.mkDerivation rec {
            inherit pname version;
            src = ../.;
            buildInputs = [ sh ];
            phases = [ "unpackPhase" "installPhase" ];

            installPhase = ''
              mkdir -p $out
              cp -r src/* $out
              cp README.md LICENSE $out/
              substituteInPlace $out/dry-wit \
                --replace "#!/usr/bin/env bash" "#!/usr/bin/env ${sh}/bin/${sh-name}"
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        defaultPackage = packages.default;
        packages = rec {
          default = dry-wit-default;
          dry-wit-default = dry-wit-bash5;
          dry-wit-bash5 = dry-wit-for {
            sh = pkgs.bash_5;
            sh-name = "bash";
          };
          dry-wit-zsh = dry-wit-for {
            sh = pkgs.zsh;
            sh-name = "zsh";
          };
          dry-wit-fish = dry-wit-for {
            sh = pkgs.fish;
            sh-name = "fish";
          };
        };
      });
}
