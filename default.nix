{ pkgs ? import <nixpkgs> {} }:

(pkgs.callPackage (import ./site.nix) { }).site
