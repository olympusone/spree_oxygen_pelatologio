# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-01-15

### Changed
- Align importmap integration with Spree Admin: draw the extension importmap via the `spree_admin.importmap` pipeline, and register cache sweepers conditionally when reloading + importmap cache sweeping are enabled.
- Normalize the Stimulus controller registration to kebab-case (`spree-oxygen-pelatologio`).

### Removed
- Remove leftover debug `console.log`.

### Fixed
- Minor cleanup: fix missing trailing newlines in a few files (no functional impact).

### Upgrade notes (if applicable)
- If you reference the Stimulus controller by identifier in HTML, update `data-controller` from `spree_oxygen_pelatologio` to `spree-oxygen-pelatologio`.
