{ pkgs, depot, ... }:
rec {
  firmware = depot.users.flokli.keyboards.buildSplitKeyboard {
    name = "corneish_zen_v1";
    board = "corneish_zen_v1_%PART%";
    zephyrDepsHash = "sha256-Qe9G5YLEi9iG5QdmJCxcmQTpzUCBYkfa84zk7SVRSgQ=";
    src = depot.users.flokli.keyboards.miryoku_config;
    extraCmakeFlags = [
      "-DCONFIG_ZMK_MOUSE=y"
      "-DCONFIG_ZMK_MOUSE_SMOOTH_SCROLLING=y"
    ];
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
