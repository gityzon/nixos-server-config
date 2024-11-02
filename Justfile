# just is a command runner, Justfile is very similar to Makefile, but simpler.

# use nushell for shell commands
#set shell := ["nu", "-c"]

############################################################################
#
#  Common commands(suitable for all machines)
#
############################################################################

switch input:
  # let system totally upgrade
  sudo nixos-rebuild switch --flake .#{{input}} --show-trace -L -v

build:
  sudo nix build .#image --impure --show-trace -L -v --extra-experimental-features flakes --extra-experimental-features nix-command
