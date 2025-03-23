let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  readTree = import "${sources.kit}/readTree" { };
in

pkgs.lib.fix (
  self:
  readTree {
    path = ./.;
    args = {
      inherit pkgs;
      lib = pkgs.lib;
      root = self;
    };
  }
)
