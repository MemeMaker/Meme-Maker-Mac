//
//  GRVibrantTitleView.m
//  Visual Experiments
//
//  Created by Guilherme Rambo on 23/08/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "GRVibrantTitleView.h"

static void *_windowTitleObservationContext = &_windowTitleObservationContext;

@interface GRVibrantTitleView ()

@property (nonatomic, copy) NSString *title;

@end

@implementation GRVibrantTitleView

- (void)viewDidMoveToWindow
{
    // update the title when we get moved into a window
    self.title = self.window.title;
    
    // add ourselves as an observer so every time the title of the window changes we are notified about it
    [self.window addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:_windowTitleObservationContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != _windowTitleObservationContext) return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    self.title = self.window.title;
}

#define kTextAlignmentPadding 50.0
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    // this will make the text truncate when the titlebar gets too small
    pStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    // this will center the text
    pStyle.alignment = NSCenterTextAlignment;
    
    // make a dictionary of attributes for our title text
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont titleBarFontOfSize:13.0],
                                 NSParagraphStyleAttributeName: pStyle,
                                 // with vibrancy, the labelColor will vary depending on the background contents
                                 NSForegroundColorAttributeName: [NSColor labelColor]};
    
    NSAttributedString *textString = [[NSAttributedString alloc] initWithString:self.title attributes:attributes];
    
    // voodoo
    NSRect textRect = NSMakeRect(0, 0, NSWidth(self.bounds)-kTextAlignmentPadding, NSHeight(self.bounds));
    CGFloat widthDiff = self.bounds.size.width-textString.size.width;
    if (widthDiff <= kTextAlignmentPadding && widthDiff > 0) {
        textRect.size.width += kTextAlignmentPadding-widthDiff;
    }
    
    // draw :)
    [textString drawInRect:textRect];
}

@end
