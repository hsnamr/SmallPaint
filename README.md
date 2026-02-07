# SmallPaint

A simple pixel editor for GNUstep, similar to Windows Paint, Wine Paint, or ReactOS Paint.

## Features

- **Canvas**: Draw on a bitmap canvas (default 640×480); scrollable for larger images.
- **Tools**: Pencil (draw with foreground color), Eraser (draw with background color).
- **Color**: Foreground color via color panel (Color… button). Background is white for eraser.
- **File**: New (new image), Open (PNG, BMP, TIFF, JPEG), Save, Save As (PNG).
- **Edit**: Clear (fill canvas with background color).

## Dependencies

- **GNUstep** (gnustep-gui, gnustep-base)
- **SmallStepLib** (this project): `../SmallStepLib` in the same repository. Used for:
  - App lifecycle (`SSHostApplication`, `SSAppDelegate`)
  - Main menu (`SSMainMenu`)
  - Window style (`SSWindowStyle`)
  - File open/save dialogs (`SSFileDialog`)

No other external libraries; uses only license-compatible GNUstep/AppKit and SmallStepLib.

## Build

1. Build and install SmallStepLib:
   ```bash
   cd ../SmallStepLib
   make
   make install
   ```

2. Build SmallPaint:
   ```bash
   cd ../SmallPaint
   make
   ```

3. Run:
   ```bash
   openapp ./SmallPaint.app
   ```
   Or from the GNUstep shell: `SmallPaint`.

## License

See [LICENSE](LICENSE). SmallStepLib and GNUstep have their own licenses; use only license-compatible combinations.
