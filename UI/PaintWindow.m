//
//  PaintWindow.m
//  SmallPaint
//

#import "PaintWindow.h"
#import "CanvasView.h"
#import "SmallStep.h"
#import "SSWindowStyle.h"
#import "SSFileDialog.h"

static const CGFloat kToolStripHeight = 36.0;

@interface ColorSwatchView : NSView
@property (nonatomic, strong) NSColor *fillColor;
@end
@implementation ColorSwatchView
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    NSColor *c = _fillColor ?: [NSColor blackColor];
    [c setFill];
    NSRectFill([self bounds]);
    [[NSColor grayColor] setStroke];
    NSFrameRect([self bounds]);
}
@end

static const CGFloat kMargin = 8.0;
static const NSInteger kDefaultNewWidth  = 640;
static const NSInteger kDefaultNewHeight = 480;

@interface PaintWindow () <CanvasViewDelegate>
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) CanvasView *canvasView;
@property (nonatomic, strong) NSView *toolStrip;
@property (nonatomic, strong) NSButton *pencilButton;
@property (nonatomic, strong) NSButton *eraserButton;
@property (nonatomic, strong) NSButton *colorButton;
@property (nonatomic, strong) ColorSwatchView *colorSwatch;
@property (nonatomic, copy) NSString *documentPath;  // nil if unsaved
@property (nonatomic, assign) BOOL documentDirty;
@end

@implementation PaintWindow

- (instancetype)init {
    NSUInteger style = [SSWindowStyle standardWindowMask];
    NSRect frame = NSMakeRect(100, 100, 700, 540);
    self = [super initWithContentRect:frame
                            styleMask:style
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setTitle:@"Untitled - SmallPaint"];
        [self setReleasedWhenClosed:NO];
        _documentPath = nil;
        _documentDirty = NO;
        [self buildContent];
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_scrollView release];
    [_canvasView release];
    [_toolStrip release];
    [_pencilButton release];
    [_eraserButton release];
    [_colorButton release];
    [_colorSwatch release];
    [_documentPath release];
    [super dealloc];
}
#endif

- (void)buildContent {
    NSView *content = [self contentView];
    NSRect contentBounds = [content bounds];
    CGFloat stripY = contentBounds.size.height - kToolStripHeight - kMargin;

    _toolStrip = [[NSView alloc] initWithFrame:NSMakeRect(0, stripY, contentBounds.size.width, kToolStripHeight)];
    [_toolStrip setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [content addSubview:_toolStrip];

    CGFloat x = kMargin;
    _pencilButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, 4, 70, 28)];
    [_pencilButton setTitle:@"Pencil"];
    [_pencilButton setButtonType:NSMomentaryPushInButton];
    [_pencilButton setBezelStyle:NSRoundedBezelStyle];
    [_pencilButton setTarget:self];
    [_pencilButton setAction:@selector(selectPencil:)];
    [_toolStrip addSubview:_pencilButton];
    x += 78;

    _eraserButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, 4, 70, 28)];
    [_eraserButton setTitle:@"Eraser"];
    [_eraserButton setButtonType:NSMomentaryPushInButton];
    [_eraserButton setBezelStyle:NSRoundedBezelStyle];
    [_eraserButton setTarget:self];
    [_eraserButton setAction:@selector(selectEraser:)];
    [_toolStrip addSubview:_eraserButton];
    x += 78;

    _colorSwatch = [[ColorSwatchView alloc] initWithFrame:NSMakeRect(x, 6, 24, 24)];
    [_colorSwatch setFillColor:[NSColor blackColor]];
    [_toolStrip addSubview:_colorSwatch];

    _colorButton = [[NSButton alloc] initWithFrame:NSMakeRect(x + 28, 4, 60, 28)];
    [_colorButton setTitle:@"Color…"];
    [_colorButton setButtonType:NSMomentaryPushInButton];
    [_colorButton setBezelStyle:NSRoundedBezelStyle];
    [_colorButton setTarget:self];
    [_colorButton setAction:@selector(chooseColor:)];
    [_toolStrip addSubview:_colorButton];

    NSRect scrollFrame = NSMakeRect(0, 0, contentBounds.size.width, stripY);
    _scrollView = [[NSScrollView alloc] initWithFrame:scrollFrame];
    [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:YES];
    [_scrollView setBorderType:NSBezelBorder];
    [_scrollView setAutohidesScrollers:YES];

    _canvasView = [[CanvasView alloc] initWithFrame:NSZeroRect];
    [_canvasView setDelegate:self];
    [_scrollView setDocumentView:_canvasView];
    [content addSubview:_scrollView];

#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_scrollView release];
    [_canvasView release];
    [_toolStrip release];
    [_pencilButton release];
    [_eraserButton release];
    [_colorButton release];
    [_colorSwatch release];
#endif
}

- (void)selectPencil:(id)sender {
    (void)sender;
    [_canvasView setTool:0];
}

- (void)selectEraser:(id)sender {
    (void)sender;
    [_canvasView setTool:1];
}

- (void)chooseColor:(id)sender {
    (void)sender;
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    [panel setColor:[_canvasView foregroundColor]];
    [panel setTarget:self];
    [panel setAction:@selector(colorPanelChanged:)];
    [panel orderFront:nil];
}

- (void)colorPanelChanged:(id)sender {
    if ([sender isKindOfClass:[NSColorPanel class]]) {
        NSColor *c = [(NSColorPanel *)sender color];
    [_canvasView setForegroundColor:c];
    [_colorSwatch setFillColor:c];
    [_colorSwatch setNeedsDisplay:YES];
    }
}

- (void)canvasViewDidChange:(CanvasView *)canvasView {
    (void)canvasView;
    _documentDirty = YES;
    [self updateTitle];
}

- (void)updateTitle {
    NSString *name = _documentPath ? [_documentPath lastPathComponent] : @"Untitled";
    if (_documentDirty) name = [name stringByAppendingString:@" *"];
    [self setTitle:[NSString stringWithFormat:@"%@ - SmallPaint", name]];
}

- (void)newDocument {
    [_canvasView newImageWithWidth:kDefaultNewWidth height:kDefaultNewHeight];
    _documentPath = nil;
    _documentDirty = NO;
    [self setTitle:@"Untitled - SmallPaint"];
}

- (void)openDocument {
    SSFileDialog *dialog = [SSFileDialog openDialog];
    [dialog setAllowedFileTypes:[NSArray arrayWithObjects:@"png", @"bmp", @"tiff", @"tif", @"jpg", @"jpeg", nil]];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    if (!path.length) return;
    if ([_canvasView setImageFromFile:path]) {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_documentPath release];
        _documentPath = [path copy];
#else
        _documentPath = [path copy];
#endif
        _documentDirty = NO;
        [self updateTitle];
    }
}

- (void)saveDocument {
    if (_documentPath.length) {
        [self saveToPath:_documentPath];
        return;
    }
    [self saveDocumentAs];
}

- (void)clearDocument {
    [_canvasView clear];
}

- (void)saveDocumentAs {
    SSFileDialog *dialog = [SSFileDialog saveDialog];
    [dialog setAllowedFileTypes:[NSArray arrayWithObjects:@"png", nil]];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    if (!path.length) return;
    if (![[path pathExtension] length])
        path = [path stringByAppendingPathExtension:@"png"];
    if ([self saveToPath:path]) {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_documentPath release];
        _documentPath = [path copy];
#else
        _documentPath = [path copy];
#endif
        _documentDirty = NO;
        [self updateTitle];
    }
}

- (BOOL)saveToPath:(NSString *)path {
    NSImage *img = [_canvasView image];
    if (!img) return NO;
    NSBitmapImageRep *rep = nil;
    for (NSImageRep *r in [img representations]) {
        if ([r isKindOfClass:[NSBitmapImageRep class]]) {
            rep = (NSBitmapImageRep *)r;
            break;
        }
    }
    if (!rep) {
        NSInteger w = (NSInteger)[img size].width;
        NSInteger h = (NSInteger)[img size].height;
        rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                     pixelsWide:w pixelsHigh:h
                                                  bitsPerSample:8 samplesPerPixel:4
                                                         hasAlpha:YES isPlanar:NO
                                                   colorSpaceName:NSDeviceRGBColorSpace
                                                      bytesPerRow:w * 4 bitsPerPixel:32];
        if (!rep) return NO;
        NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:ctx];
        [img drawInRect:NSMakeRect(0, 0, (CGFloat)w, (CGFloat)h) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [rep autorelease];
#endif
    }
    NSData *pngData = [rep representationUsingType:NSPNGFileType properties:[NSDictionary dictionary]];
    if (!pngData) return NO;
    return [pngData writeToFile:path atomically:YES];
}

@end
