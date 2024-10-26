{ pkgs, lib, ... }:
let
  zmk-nix = pkgs.fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "zmk-nix";
    rev = "d72e94ab94b2bceb60a29a2a8c2e1d304a4e922e";
    hash = "sha256-3WXPPBJ2u8rMxejPhUahSiqOBr1BOfTgDa7oQDPtw54=";
  };

  builders = pkgs.callPackage (import (zmk-nix + "/nix/builders.nix")) { };

  miryoku_zmk = pkgs.fetchFromGitHub {
    owner = "manna-harbour";
    repo = "miryoku_zmk";
    rev = "e6683e9f8b6c199b339208b1b501e88a7308ed48";
    hash = "sha256-GjTbAoyhr557Tn4JaWsA3Po5KxMsQXrpKc9H+PU3T8A=";
  };

  miryoku_zmk_patched = pkgs.runCommand "miryoku_zmk_patched" { } ''
    mkdir -p $out
    cp -r ${miryoku_zmk}/. $out/
    cd $out
    chmod -R +w $out
    patch -p1 < ${./0001-miryoku_layer_alternatives.h-expose-alt-gr-on-G-and-.patch}
    patch -p1 < ${./0001-miryoku_behaviors-add-quick-tap-ms-require-prior-idl.patch}
  '';

in

rec {
  config = pkgs.runCommand "config" { } ''
    mkdir -p $out/config
    cp -r ${miryoku_zmk_patched}/miryoku $out/
    cp ${./west.yml} $out/config/west.yml
    cp ${miryoku_zmk_patched}/config/corneish_zen.keymap $out/config/
  '';

  # helpful for debugging the resulting keymap
  config-flat = pkgs.runCommand "config-flat"
    {
      nativeBuildInputs = [ pkgs.python3.pkgs.pcpp ];
    } ''
    mkdir -p $out/config
    cp ${./west.yml} $out/config/west.yml
    pcpp --passthru-unfound-includes -o $out/config/corneish_zen.keymap ${miryoku_zmk_patched}/config/corneish_zen.keymap
  '';

  firmware = builders.buildSplitKeyboard {
    name = "corneish_zen_v1";
    board = "corneish_zen_v1_%PART%";
    zephyrDepsHash = "sha256-D5CAlrO/E6DPbtUJyh/ec8ACpo1XM1jx2gLS2TpklBQ=";
    src = config;
  };

  flash-left = pkgs.writeShellScript "flash.sh" ''
    cp ${firmware}/zmk_left.uf2 /run/media/$USER/CORNEISHZEN/
  '';

  flash-right = pkgs.writeShellScript "flash.sh" ''
    cp ${firmware}/zmk_right.uf2 /run/media/$USER/CORNEISHZEN/
  '';
}
