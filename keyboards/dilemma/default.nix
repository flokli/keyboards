{ depot, pkgs, ... }:

rec {
  qmk_firmware_src = pkgs.fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = "728aa576b0cd65c6fb7cf77132fdcd06fcedb643"; # develop branch
    hash = "sha256-YmdX8nEsB1R8d265HAmvwejPjEHJdoTnm4QNigzrcyw=";
    fetchSubmodules = true;
  };

  firmware = pkgs.stdenv.mkDerivation {
    name = "keychron-bastardkb-dilemma-firmware";

    src = qmk_firmware_src;

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
    QMK_HOME=${qmk_firmware_src} ${pkgs.qmk}/bin/qmk flash ${firmware}/bastardkb_dilemma_3x5_3_flokli.uf2
  '';

  meta.ci.targets = [ "firmware" ];
}
