//
//  GRTitlebarView.m
//  Visual Experiments
//
//  Created by Guilherme Rambo on 23/08/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "GRVibrantTitlebarView.h"

#import "GRVibrantTitleView.h"
#import "GRSeparatorLineView.h"

@interface GRVibrantTitlebarView ()

@property (nonatomic, strong) GRSeparatorLineView *lineView;

@end

@implementation GRVibrantTitlebarView

#define kTitleTopOffset 2.0
#define kTitleLeftOffset 70.0
#define kTitleHeight 14.0
- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (!self) return nil;
    
    self.lineView = [[GRSeparatorLineView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), 1.0)];
    self.lineView.autoresizingMask = NSViewWidthSizable|NSViewMaxYMargin;
    [self addSubview:self.lineView];
    
    self.titleView = [[GRVibrantTitleView alloc] initWithFrame:NSMakeRect(kTitleLeftOffset, NSHeight(self.frame)-kTitleHeight-kTitleTopOffset, NSWidth(self.frame)-kTitleLeftOffset, kTitleHeight)];
    self.titleView.autoresizingMask = NSViewWidthSizable|NSViewMinYMargin;
    [self addSubview:self.titleView];
    
    return self;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSWindow *window = self.window;
    if (window.isMovableByWindowBackground || (window.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask) {
        [super mouseDragged:theEvent];
        return;
    }
    
    NSPoint where = [window convertRectToScreen:NSMakeRect(theEvent.locationInWindow.x, theEvent.locationInWindow.y, 0, 0)].origin;
    NSPoint origin = window.frame.origin;
    CGFloat deltaX = 0.0;
    CGFloat deltaY = 0.0;
    while ((theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES]) && (theEvent.type != NSLeftMouseUp)) {
        @autoreleasepool {
            NSPoint now = [window convertRectToScreen:NSMakeRect(theEvent.locationInWindow.x, theEvent.locationInWindow.y, 0, 0)].origin;
            deltaX += now.x - where.x;
            deltaY += now.y - where.y;
            if (fabs(deltaX) >= 1 || fabs(deltaY) >= 1) {
                // This part is only called if drag occurs on container view!
                origin.x += deltaX;
                origin.y += deltaY;
                window.frameOrigin = origin;
                deltaX = 0.0;
                deltaY = 0.0;
            }
            where = now; // this should be inside above if but doing that results in jittering while moving the window...
        }
    }
}

@end
