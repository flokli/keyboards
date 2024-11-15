{ pkgs, depot, ... }:
rec {
  firmware = depot.users.flokli.keyboards.buildSplitKeyboard {
    name = "nice_nano_v2";
    board = "nice_nano_v2";
    shield = "corne_%PART% nice_view_adapter nice_view";
    zephyrDepsHash = "sha256-Qe9G5YLEi9iG5QdmJCxcmQTpzUCBYkfa84zk7SVRSgQ=";
    src = depot.users.flokli.keyboards.miryoku_config;
    extraCmakeFlags = [
      "-DCONFIG_ZMK_MOUSE=y"
      "-DCONFIG_ZMK_MOUSE_SMOOTH_SCROLLING=y"
    ];
  };

  config-flat = depot.users.flokli.keyboards.mkFlatConfig "corne";

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
