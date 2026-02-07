//
//  AppDelegate.m
//  SmallPaint
//

#import "AppDelegate.h"
#import "PaintWindow.h"
#import "SmallStep.h"
#import "SSMainMenu.h"
#import "SSHostApplication.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching {
    [self buildMenu];
}

- (void)applicationDidFinishLaunching {
    _mainWindow = [[PaintWindow alloc] init];
    [_mainWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    return YES;
}

- (void)buildMenu {
#if !TARGET_OS_IPHONE
    SSMainMenu *menu = [[SSMainMenu alloc] init];
    [menu setAppName:@"SmallPaint"];
    NSArray *items = [NSArray arrayWithObjects:
        [SSMainMenuItem itemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Open…" action:@selector(openDocument:) keyEquivalent:@"o" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:@"s" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Save As…" action:@selector(saveDocumentAs:) keyEquivalent:@"" modifierMask:0 target:self],
        [SSMainMenuItem itemWithTitle:@"Clear" action:@selector(clearDocument:) keyEquivalent:@"" modifierMask:0 target:self],
        nil];
    [menu buildMenuWithItems:items quitTitle:@"Quit SmallPaint" quitKeyEquivalent:@"q"];
    [menu install];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [menu release];
#endif
#endif
}

- (void)newDocument:(id)sender {
    (void)sender;
    [_mainWindow newDocument];
}

- (void)openDocument:(id)sender {
    (void)sender;
    [_mainWindow openDocument];
}

- (void)saveDocument:(id)sender {
    (void)sender;
    [_mainWindow saveDocument];
}

- (void)saveDocumentAs:(id)sender {
    (void)sender;
    [_mainWindow saveDocumentAs];
}

- (void)clearDocument:(id)sender {
    (void)sender;
    [_mainWindow clearDocument];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_mainWindow release];
    [super dealloc];
}
#endif

@end
