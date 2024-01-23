{ depot, pkgs, ... }:

rec {
  firmware = pkgs.stdenv.mkDerivation {
    name = "keychron-bastardkb-dilemma-firmware";

    src = pkgs.fetchFromGitHub {
      owner = "Bastardkb"; # the bastadrkb fork of qmk/qmk_firmware
      repo = "bastardkb-qmk";
      rev = "78b6376b073c174dee482ae3ebe4fdc572874a09"; # bkb-master
      hash = "sha256-30TqwEsLNs5Rli+RMQQMOg8AIufIZvhbetbdz9C4k/8=";
      fetchSubmodules = true;
    };

    patches = [ ./enable-taps.patch ];

    postPatch = ''
      patchShebangs util/uf2conv.py
    '';

    nativeBuildInputs = [
      pkgs.python3
      pkgs.qmk
    ];

    buildPhase = ''
      mkdir -p keyboards/bastardkb/dilemma/3x5_3/keymaps/flokli
      cp ${./keymap.c} keyboards/bastardkb/dilemma/3x5_3/keymaps/flokli/keymap.c
      cp ${./rules.mk} keyboards/bastardkb/dilemma/3x5_3/keymaps/flokli/rules.mk

      make bastardkb/dilemma/3x5_3:flokli
    '';

    installPhase = ''
      mkdir -p $out
      cp bastardkb_dilemma_3x5_3_flokli.uf2 $out/
    '';
  };

  flash = pkgs.writeShellScript "flash.sh" ''
    ${pkgs.qmk}/bin/qmk flash ${firmware}/bastardkb_dilemma_3x5_3_flokli.uf2
  '';

  meta.ci.targets = [ "firmware" ];
}
