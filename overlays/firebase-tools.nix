# Standalone overlay for firebase-tools
# This file exports a single overlay function that forces `firebase-tools`
# to use `nodejs_22` when available, falling back to `nodejs` otherwise.
#
# firebase-tools uses buildNpmPackage which accepts nodejs as a parameter.
# We override buildNpmPackage to use the desired nodejs version.
final: prev:
let
  # Prefer nodejs_22 if present in the previous package set; otherwise use nodejs.
  nodejsChoice = if builtins.hasAttr "nodejs_22" prev then prev.nodejs_22 else prev.nodejs;
in
{
  # Override firebase-tools by providing a custom buildNpmPackage with our nodejs choice
  firebase-tools = prev.firebase-tools.override {
    buildNpmPackage = prev.buildNpmPackage.override {
      nodejs = nodejsChoice;
    };
  };
}
