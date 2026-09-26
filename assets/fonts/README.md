# Bundled fonts

These are the exact regular font binaries referenced by google_fonts 6.2.1, retained to preserve the letter metrics used by the tracing checkpoints.

- Press Start 2P: https://fonts.gstatic.com/s/a/8e9e854f71aebd3bb8342321d0cc92cabf68e27354dd7a90e806bce895da8dca.ttf
- Poppins: https://fonts.gstatic.com/s/a/705290b12f58c6d70aafcaaf461dbc3d2f7f19d0f4362af1843b107d95d4960a.ttf

Each URL's filename is also the verified SHA-256 checksum. The accompanying OFL notices were retrieved from the respective `ofl/pressstart2p` and `ofl/poppins` directories of https://github.com/google/fonts. They apply to these font files, not to the Letterchamp source code or other artwork/audio.

Runtime font downloads are disabled in `lib/main.dart`. When upgrading google_fonts or changing fonts, verify offline loading and alignment with the hand-authored tracing paths.
