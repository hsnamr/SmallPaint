//
//  PaintWindow.h
//  SmallPaint
//
//  Main window: canvas in scroll view, tool strip, color. Handles New/Open/Save via SSFileDialog.
//

#import <AppKit/AppKit.h>

@interface PaintWindow : NSWindow

- (void)newDocument;
- (void)openDocument;
- (void)saveDocument;
- (void)saveDocumentAs;
- (void)clearDocument;

@end
