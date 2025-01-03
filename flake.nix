{
  description = "basic c flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
	inherit system;
      };
      st = pkgs.stdenv.mkDerivation rec {
	pname = "st";
	version = "0.9.2";
	src = ./.;

        outputs = [
          "out"
          "terminfo"
        ];

        makeFlags = [
          "PKG_CONFIG=${pkgs.stdenv.cc.targetPrefix}pkg-config"
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config
          ncurses
          fontconfig
          freetype
        ];

	buildInputs = with pkgs.xorg; [
	  libX11
	  libXft
	];

        preInstall = ''
          export TERMINFO=$terminfo/share/terminfo
          mkdir -p $TERMINFO $out/nix-support
          echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
        '';

        installFlags = [ "PREFIX=$(out)" ];
      };
    in {
      packages.${system}.default = st;
    };
}
