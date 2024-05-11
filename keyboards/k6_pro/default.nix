{ depot, pkgs, ... }:

rec {
  qmk_firmware_src = pkgs.fetchFromGitHub {
    owner = "Keychron"; # the Keychron fork of qmk/qmk_firmware
    repo = "qmk_firmware";
    rev = "e0a48783e7cde92d1edfc53a8fff511c45e869d4"; # bluetooth_playground branch
    hash = "sha256-Pk9kXktmej9JyvSt7UMEW2FDrBg7k1lOssh6HjrP5ro=";
    fetchSubmodules = true;
  };

  firmware = pkgs.stdenv.mkDerivation {
    name = "keychron-k6_pro-firmware";

    src = qmk_firmware_src;

    nativeBuildInputs = [
      pkgs.qmk
    ];

    buildPhase = ''
      mkdir -p keyboards/keychron/k6_pro/ansi/rgb/keymaps/flokli
      cp ${./keymap.c} keyboards/keychron/k6_pro/ansi/rgb/keymaps/flokli/keymap.c
      cp ${./rules.mk} keyboards/keychron/k6_pro/ansi/rgb/keymaps/flokli/rules.mk

      make keychron/k6_pro/ansi/rgb:flokli
    '';

    installPhase = ''
      mkdir -p $out

      cp keychron_k6_pro_ansi_rgb_flokli.bin $out/
    '';
  };

  flash = pkgs.writeShellScript "flash.sh" ''
    QMK_HOME=${qmk_firmware_src} ${pkgs.qmk}/bin/qmk flash ${firmware}/keychron_k6_pro_ansi_rgb_flokli.bin
  '';

  meta.ci.targets = [ "firmware" ];
}
