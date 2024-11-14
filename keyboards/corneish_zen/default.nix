{ pkgs, depot, ... }:
rec {
  firmware = depot.users.flokli.keyboards.buildSplitKeyboard {
    name = "corneish_zen_v1";
    board = "corneish_zen_v1_%PART%";
    zephyrDepsHash = "sha256-D5CAlrO/E6DPbtUJyh/ec8ACpo1XM1jx2gLS2TpklBQ=";
    src = depot.users.flokli.keyboards.miryoku_config;
  };

  config-flat = depot.users.flokli.keyboards.mkFlatConfig "corneish_zen";

  flash-left = pkgs.writeShellScript "flash.sh" ''
    cp ${firmware}/zmk_left.uf2 /run/media/$USER/CORNEISHZEN/
  '';

  flash-right = pkgs.writeShellScript "flash.sh" ''
    cp ${firmware}/zmk_right.uf2 /run/media/$USER/CORNEISHZEN/
  '';

  meta.ci.targets = [
    "config-flat"
    "firmware"
  ];
}
