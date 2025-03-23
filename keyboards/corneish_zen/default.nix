{ pkgs, root, ... }:
rec {
  firmware = root.keyboards.buildSplitKeyboard {
    name = "corneish_zen_v1";
    board = "corneish_zen_v1_%PART%";
    zephyrDepsHash = "sha256-YE2iVzWk48rPxEWuBAcJPNEFvKB/+FoLUiYVCTsBI8M=";
    src = root.keyboards.miryoku_config;
    extraCmakeFlags = [
      "-DCONFIG_ZMK_MOUSE=y"
      "-DCONFIG_ZMK_MOUSE_SMOOTH_SCROLLING=y"
    ];
  };

  config-flat = root.keyboards.mkFlatConfig "corneish_zen";

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
