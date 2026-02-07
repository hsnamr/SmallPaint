//
//  CanvasView.h
//  SmallPaint
//
//  Custom view that holds a pixel bitmap and handles drawing (pencil/eraser).
//

#import <AppKit/AppKit.h>

@class CanvasView;

@protocol CanvasViewDelegate <NSObject>
@optional
- (void)canvasViewDidChange:(CanvasView *)canvasView;
@end

@interface CanvasView : NSView
@property (nonatomic, assign) NSInteger tool;           // 0 = Pencil, 1 = Eraser
@property (nonatomic, strong) NSColor *foregroundColor;
@property (nonatomic, strong) NSColor *backgroundColor; // used for eraser
@property (nonatomic, assign) CGFloat brushSize;        // pixel radius for brush
@property (nonatomic, weak) id<CanvasViewDelegate> delegate;

/// Create or replace the bitmap with a new empty image (width x height). Clears to white.
- (void)newImageWithWidth:(NSInteger)width height:(NSInteger)height;

/// Replace the bitmap with the given image (e.g. from file). Keeps size.
- (BOOL)setImageFromFile:(NSString *)path;

/// Replace the bitmap with the given NSImage (e.g. from paste or open).
- (BOOL)setImage:(NSImage *)image;

/// Current bitmap as NSImage (for save/copy).
- (NSImage *)image;

/// Current bitmap size in pixels.
- (NSSize)imageSizeInPixels;

/// Clear canvas to background color.
- (void)clear;
@end
