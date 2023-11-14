# dry-wit

This is dry-wit, a framework for bash scripts.

This project is useful when writing new scripts. It provides a common
layout and a toolbox of functions to help writing shell scripts from
scratch.

Since Bash is an interpreted language, you can review the contents of
dry-wit yourself.

It comes with a number of [modules](https://github.com/rydnr/dry-wit/tree/main/src/modules "modules").

## Usage

- Use this shebang in your scripts.

``` sh
#!/usr/bin/env dry-wit
```

- Write the only mandatory function `main()`

The `main()` function is the starting point of your script. You don't need to care about anything but the funcional requirements of your script.

## Examples

You can check other dry-wit scripts as a reference. For example, <https://github.com/rydnr/update-sha256-in-nix-flake/tree/main/src/update-sha256-in-nix-flake.sh>.

## Installation for Nix users

If you are a Nix user, you can create your own scripts using dry-wit and package them as Nix flakes too.

Here's a template you can use, assuming the script is in a git repository under the `src/` subfolder.

``` nix
#
# Sample flake for a dry-wit script.
#
{
  description = "A dry-wit script";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    dry-wit = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:rydnr/dry-wit/3.0.3?dir=nix";
    };
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
        org = "[your-user]";
        repo = "[the-script-repo]";
        pname = "${org}-${repo}";
        version = "0.0.1";
        pkgs = import nixos { inherit system; };
        description =
          "A dry-wit script";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        my-script-for = { dry-wit }:
          pkgs.stdenv.mkDerivation rec {
            inherit pname version;
            src = ../.;
            buildInputs = [ dry-wit ];
            phases = [ "unpackPhase" "installPhase" ];

            installPhase = ''
              mkdir -p $out/bin
              cp -r src/* $out/bin
              chmod +x $out/bin/*
              cp README.md LICENSE $out/
              for f in $out/bin/*.sh; do
                substituteInPlace $f \
                  --replace "#!/usr/bin/env dry-wit" "#!/usr/bin/env ${dry-wit}/dry-wit"
              done
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        defaultPackage = packages.default;
        packages = rec {
          default = update-sha256-in-nix-flake-default;
          my-script-default = my-script-bash5;
          my-script-bash5 = my-script-for {
            dry-wit = dry-wit.packages.${system}.dry-wit-bash5;
          };
          my-script-zsh = my-script-for {
            dry-wit = dry-wit.packages.${system}.dry-wit-zsh;
          };
          my-script-fish = my-script-for {
            dry-wit = dry-wit.packages.${system}.dry-wit-fish;
          };
        };
      });
}
```

## Manual installation

Basically, in order to write dry-wit scripts you'll need to do the following:

- Clone this repository under `~/.dry-wit`:

``` sh
  git clone https://github.com/rydnr/dry-wit $HOME/.dry-wit
```

- Add `~/.dry-wit/src` to your PATH:

``` sh
echo 'export PATH=$PATH:$HOME/.dry-wit/src' >> $HOME/.bashrc
```

### MacOS X

Note for Mac OS X users:

- Your MacOS X might come with an old version of Bash. dry-wit requires Bash 4+. To use a recent version, install homebrew, then bash, and run

``` sh
chsh -s /usr/local/bin/bash
```

- Additionally, dry-wit requires the following brew formulae:
  - greadlink
  - coreutils
  - pidof
  - wget

``` sh
brew install greadlink
brew install coreutils
brew install pidof
brew install wget
```

