{ pkgs, ... }:


let
  zmk-nix = pkgs.fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "zmk-nix";
    rev = "1d7d7aeef7c62d3a80a688b26c6484123c26cde6";
    hash = "sha256-7W+slivoV0zSfDxXlhMVL3yPodrhCiYQiFbtbco1r5U=";
  };

  zmk_builders = pkgs.callPackage (import (zmk-nix + "/nix/builders.nix")) { };

  miryoku_zmk = pkgs.fetchFromGitHub {
    owner = "manna-harbour";
    repo = "miryoku_zmk";
    rev = "a1f1eae0666b7b33ad789b10822297169754a349";
    hash = "sha256-4jYz5fudTW45hbwhRRGBdiAbu596X9zSiCio/tS85d0=";
  };

  miryoku_zmk_patched = pkgs.runCommand "miryoku_zmk_patched" { } ''
    mkdir -p $out
    cp -r ${miryoku_zmk}/. $out/
    cd $out
    chmod -R +w $out
    patch -p1 < ${./0001-miryoku_layer_alternatives.h-expose-alt-gr-on-G-and-.patch}
    patch -p1 < ${./0001-miryoku_behaviors-add-quick-tap-ms-require-prior-idl.patch}
    patch -p1 < ${./0001-custom_config-define-MIRYOKU_KLUDGE_MOUSEKEYSPR.patch}
  '';

  miryoku_config = pkgs.runCommand "config" { } ''
    mkdir -p $out/config
    cp -r ${miryoku_zmk_patched}/miryoku $out/
    cp ${./west.yml} $out/config/west.yml
    cp ${miryoku_zmk_patched}/config/*.keymap $out/config/
  '';

  # helpful for debugging a resulting keymap config
  mkFlatConfig = name: pkgs.runCommand "config-flat"
    {
      nativeBuildInputs = [ pkgs.python3.pkgs.pcpp ];
    } ''
    mkdir -p $out/config
    cp ${./west.yml} $out/config/west.yml
    pcpp --passthru-unfound-includes -o $out/config/${name}.keymap ${miryoku_zmk_patched}/config/${name}.keymap
  '';

in

{
  miryoku_zmk = miryoku_zmk_patched;
  inherit (zmk_builders) buildSplitKeyboard;
  inherit miryoku_config mkFlatConfig;
}
