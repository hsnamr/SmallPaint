//
//  AppDelegate.h
//  SmallPaint
//
//  App lifecycle and menu; creates the main paint window.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif
#import "SmallStep.h"

@class PaintWindow;

@interface AppDelegate : NSObject <SSAppDelegate>
{
    PaintWindow *_mainWindow;
}
@end
