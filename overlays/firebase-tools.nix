# Standalone overlay for firebase-tools
# This file exports a single overlay function that forces `firebase-tools`
# to use `nodejs_22` when available, falling back to `nodejs` otherwise.
#
# It's intended to be imported directly in a host's `nixpkgs.overlays`,
# e.g. in `hosts/server/configuration.nix`.
final: prev:
let
  # Prefer nodejs_22 if present in the previous package set; otherwise use nodejs.
  nodejsChoice = if builtins.hasAttr "nodejs_22" prev then prev.nodejs_22 else prev.nodejs;
in
{
  # Override firebase-tools to use the chosen Node.js package.
  firebase-tools = prev.firebase-tools.override {
    nodejs = nodejsChoice;
  };
}
