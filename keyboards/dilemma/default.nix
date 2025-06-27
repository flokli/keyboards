{ pkgs, ... }:

rec {
  qmk_firmware_src = pkgs.fetchFromGitHub {
    owner = "george-norton";
    repo = "qmk_firmware";
    rev = "6a0f25033ebb7f901eb03dad2d598f949d424ea0"; # multitouch_experiment
    hash = "sha256-yCU3+BADqqiL6/sHk1tlEbXrG5Z2Mqb/wBhb9rXSvxQ=";
    fetchSubmodules = true;
  };

  qmk_userspace = pkgs.fetchFromGitHub {
    owner = "bastardkb";
    repo = "qmk_userspace";
    rev = "722fe10ae9f1249245af4852209694749207eb70"; # develop
    hash = "sha256-FY5zyM6G6DEdSWowNADrHr9P5G4mqioTDK/KM10z6t0=";
    fetchSubmodules = true;
  };

  firmware = pkgs.stdenv.mkDerivation {
    name = "bastardkb-dilemma-firmware";

    src = qmk_firmware_src;

    patches = [ ./enable-taps.patch ];

    postPatch = ''
      patchShebangs util/uf2conv.py
    '';

    nativeBuildInputs = [
      pkgs.python3
      pkgs.qmk
    ];

    env.QMK_HOME = qmk_firmware_src;
    env.QMK_USERSPACE = "/tmp/qmk_userspace";
    env.HOME = "/tmp/qmk";
    env.SKIP_GIT = "true";

    buildPhase = ''
      mkdir -p /tmp/qmk_userspace
      cp -r ${qmk_userspace}/. /tmp/qmk_userspace/
      chmod +w /tmp/qmk_userspace/ --recursive

      mkdir -p /tmp/qmk_userspace/keyboards/bastardkb/dilemma/3x5_3{,_procyon}/keymaps/flokli
      cp ${./keymap.c} /tmp/qmk_userspace/keyboards/bastardkb/dilemma/3x5_3/keymaps/flokli/keymap.c
      cp ${./rules.mk} /tmp/qmk_userspace/keyboards/bastardkb/dilemma/3x5_3/keymaps/flokli/rules.mk
      cp ${./keymap.c} /tmp/qmk_userspace/keyboards/bastardkb/dilemma/3x5_3_procyon/keymaps/flokli/keymap.c
      cp ${./rules.mk} /tmp/qmk_userspace/keyboards/bastardkb/dilemma/3x5_3_procyon/keymaps/flokli/rules.mk

      qmk compile -c -kb bastardkb/dilemma/3x5_3 -km flokli
      qmk compile -c -kb bastardkb/dilemma/3x5_3_procyon -km flokli
    '';

    installPhase = ''
      mkdir -p $out
      cp bastardkb_dilemma_*.uf2 $out/
    '';
  };

  flash-v2 = pkgs.writeShellScript "flash.sh" ''
    QMK_HOME=${qmk_firmware_src} ${pkgs.qmk}/bin/qmk flash ${firmware}/bastardkb_dilemma_3x5_3_flokli.uf2
  '';
  flash-v3 = pkgs.writeShellScript "flash.sh" ''
    QMK_HOME=${qmk_firmware_src} ${pkgs.qmk}/bin/qmk flash ${firmware}/bastardkb_dilemma_3x5_3_procyon_flokli.uf2
  '';

  meta.ci.skip = true;
  meta.ci.targets = [ "firmware" ];
}
