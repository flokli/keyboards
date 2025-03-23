{ pkgs, root, ... }:
rec {
  firmware = root.keyboards.buildSplitKeyboard {
    name = "nice_nano_v2";
    board = "nice_nano_v2";
    shield = "corne_%PART% nice_view_adapter nice_view";
    zephyrDepsHash = "sha256:1hr304xhj596a85mmy3zl2y0bl9w143h9bj5qk7wmqx46mbs4kb0";
    src = root.keyboards.miryoku_config;
    extraCmakeFlags = [
      "-DCONFIG_ZMK_POINTING=y"
      "-DCONFIG_ZMK_POINTING_SMOOTH_SCROLLING=y"
    ];
  };

  config-flat = root.keyboards.mkFlatConfig "corne";

  flash-left = pkgs.writeShellScript "flash.sh" ''
    cp ${firmware}/zmk_left.uf2 /run/media/$USER/NICENANO/
  '';

  flash-right = pkgs.writeShellScript "flash.sh" ''
    cp ${firmware}/zmk_right.uf2 /run/media/$USER/NICENANO/
  '';

  meta.ci.targets = [
    "config-flat"
    "firmware"
  ];
}
