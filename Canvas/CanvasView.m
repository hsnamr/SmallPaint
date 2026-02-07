//
//  CanvasView.m
//  SmallPaint
//

#import "CanvasView.h"
#import <AppKit/AppKit.h>

static const NSInteger kDefaultWidth  = 640;
static const NSInteger kDefaultHeight = 480;

@interface CanvasView ()
@property (nonatomic, strong) NSBitmapImageRep *bitmap;
@property (nonatomic, assign) BOOL trackingMouse;
@end

@implementation CanvasView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _tool = 0;
        _foregroundColor = [NSColor blackColor];
        _backgroundColor = [NSColor whiteColor];
        _brushSize = 1.0;
        _trackingMouse = NO;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_foregroundColor retain];
        [_backgroundColor retain];
#endif
        [self newImageWithWidth:kDefaultWidth height:kDefaultHeight];
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_bitmap release];
    [_foregroundColor release];
    [_backgroundColor release];
    [super dealloc];
}
#endif

- (void)newImageWithWidth:(NSInteger)width height:(NSInteger)height {
    if (width <= 0 || height <= 0) return;
    NSInteger bpp = 4;
    NSInteger rowBytes = width * bpp;
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                   pixelsWide:width
                                                                   pixelsHigh:height
                                                                bitsPerSample:8
                                                              samplesPerPixel:bpp
                                                                     hasAlpha:YES
                                                                     isPlanar:NO
                                                               colorSpaceName:NSDeviceRGBColorSpace
                                                                  bytesPerRow:rowBytes
                                                                 bitsPerPixel:32];
    if (!rep) return;
    unsigned char *data = [rep bitmapData];
    if (data) {
        size_t len = (size_t)(rowBytes * height);
        memset(data, 0xFF, len); // white + full alpha
    }
    _bitmap = rep;
    [self setFrameSize:NSMakeSize((CGFloat)width, (CGFloat)height)];
    [self setNeedsDisplay:YES];
}

- (BOOL)setImageFromFile:(NSString *)path {
    if (!path.length) return NO;
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
    BOOL ok = [self setImage:img];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [img release];
#endif
    return ok;
}

- (BOOL)setImage:(NSImage *)image {
    if (!image) return NO;
    NSSize size = [image size];
    NSInteger w = (NSInteger)size.width;
    NSInteger h = (NSInteger)size.height;
    if (w <= 0 || h <= 0) return NO;

    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                   pixelsWide:w
                                                                   pixelsHigh:h
                                                                bitsPerSample:8
                                                              samplesPerPixel:4
                                                                     hasAlpha:YES
                                                                     isPlanar:NO
                                                               colorSpaceName:NSDeviceRGBColorSpace
                                                                  bytesPerRow:w * 4
                                                                 bitsPerPixel:32];
    if (!rep) return NO;
    NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:ctx];
    [image drawInRect:NSMakeRect(0, 0, (CGFloat)w, (CGFloat)h)
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    _bitmap = rep;
    [self setFrameSize:NSMakeSize((CGFloat)w, (CGFloat)h)];
    [self setNeedsDisplay:YES];
    return YES;
}

- (NSImage *)image {
    if (!_bitmap) return nil;
    NSImage *img = [[NSImage alloc] initWithSize:NSMakeSize((CGFloat)[_bitmap pixelsWide], (CGFloat)[_bitmap pixelsHigh])];
    [img addRepresentation:_bitmap];
    return [img autorelease];
}

- (NSSize)imageSizeInPixels {
    if (!_bitmap) return NSZeroSize;
    return NSMakeSize((CGFloat)[_bitmap pixelsWide], (CGFloat)[_bitmap pixelsHigh]);
}

- (void)clear {
    if (!_bitmap) return;
    unsigned char *data = [_bitmap bitmapData];
    NSInteger w = [_bitmap pixelsWide];
    NSInteger h = [_bitmap pixelsHigh];
    NSInteger rowBytes = [_bitmap bytesPerRow];
    if (!data) return;
    CGFloat r, g, b, a;
    NSColor *bg = _backgroundColor ?: [NSColor whiteColor];
    [[bg colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
    unsigned char R = (unsigned char)(r * 255.0);
    unsigned char G = (unsigned char)(g * 255.0);
    unsigned char B = (unsigned char)(b * 255.0);
    unsigned char A = (unsigned char)(a * 255.0);
    for (NSInteger y = 0; y < h; y++) {
        unsigned char *row = data + (size_t)y * (size_t)rowBytes;
        for (NSInteger x = 0; x < w; x++) {
            row[x * 4 + 0] = R;
            row[x * 4 + 1] = G;
            row[x * 4 + 2] = B;
            row[x * 4 + 3] = A;
        }
    }
    [self setNeedsDisplay:YES];
    [_delegate canvasViewDidChange:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    if (!_bitmap) return;
    NSImage *img = [[NSImage alloc] initWithSize:NSMakeSize((CGFloat)[_bitmap pixelsWide], (CGFloat)[_bitmap pixelsHigh])];
    [img addRepresentation:_bitmap];
    [img drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [img release];
#endif
}

- (NSPoint)viewPointToPixel:(NSPoint)viewPoint {
    NSRect bounds = [self bounds];
    if (bounds.size.width <= 0 || bounds.size.height <= 0) return NSMakePoint(-1, -1);
    NSInteger w = [_bitmap pixelsWide];
    NSInteger h = [_bitmap pixelsHigh];
    CGFloat x = (viewPoint.x - bounds.origin.x) / bounds.size.width  * (CGFloat)w;
    CGFloat y = (viewPoint.y - bounds.origin.y) / bounds.size.height * (CGFloat)h;
    // View Y is bottom-up; bitmap row 0 is top in our draw
    y = (CGFloat)h - 1.0 - y;
    NSInteger ix = (NSInteger)round(x);
    NSInteger iy = (NSInteger)round(y);
    if (ix < 0 || ix >= w || iy < 0 || iy >= h) return NSMakePoint(-1, -1);
    return NSMakePoint((CGFloat)ix, (CGFloat)iy);
}

- (void)strokeAtPixelX:(NSInteger)px y:(NSInteger)py {
    if (!_bitmap) return;
    NSInteger w = [_bitmap pixelsWide];
    NSInteger h = [_bitmap pixelsHigh];
    NSInteger rowBytes = [_bitmap bytesPerRow];
    unsigned char *data = [_bitmap bitmapData];
    if (!data) return;

    NSColor *color = (_tool == 1) ? _backgroundColor : _foregroundColor;
    color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    unsigned char R = (unsigned char)(r * 255.0);
    unsigned char G = (unsigned char)(g * 255.0);
    unsigned char B = (unsigned char)(b * 255.0);
    unsigned char A = (unsigned char)(a * 255.0);

    NSInteger radius = (NSInteger)round(_brushSize);
    if (radius < 1) radius = 1;
    for (NSInteger dy = -radius; dy <= radius; dy++) {
        for (NSInteger dx = -radius; dx <= radius; dx++) {
            if (dx * dx + dy * dy > radius * radius) continue;
            NSInteger x = px + dx;
            NSInteger y = py + dy;
            if (x < 0 || x >= w || y < 0 || y >= h) continue;
            size_t idx = (size_t)y * (size_t)rowBytes + (size_t)x * 4;
            data[idx + 0] = R;
            data[idx + 1] = G;
            data[idx + 2] = B;
            data[idx + 3] = A;
        }
    }
    [self setNeedsDisplay:YES];
    [_delegate canvasViewDidChange:self];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint loc = [self convertPoint:[event locationInWindow] fromView:nil];
    NSPoint p = [self viewPointToPixel:loc];
    if (p.x >= 0 && p.y >= 0) {
        _trackingMouse = YES;
        [self strokeAtPixelX:(NSInteger)p.x y:(NSInteger)p.y];
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (!_trackingMouse) return;
    NSPoint loc = [self convertPoint:[event locationInWindow] fromView:nil];
    NSPoint p = [self viewPointToPixel:loc];
    if (p.x >= 0 && p.y >= 0)
        [self strokeAtPixelX:(NSInteger)p.x y:(NSInteger)p.y];
}

- (void)mouseUp:(NSEvent *)event {
    (void)event;
    _trackingMouse = NO;
}

@end
