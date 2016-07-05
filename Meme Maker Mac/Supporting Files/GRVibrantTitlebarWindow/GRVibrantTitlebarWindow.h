//
//  GRVibrantTitlebarWindow.h
//  Visual Experiments
//
//  Created by Guilherme Rambo on 23/08/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GRVibrantTitlebarWindow : NSWindow <NSWindowDelegate>

/**
 Set whether the window's vibrant titlebar should be hidden when the window enters fullscreen mode
 */
@property (nonatomic, assign) BOOL hidesTitlebarWhenFullscreen;

/**
 Set the titlebar's appearance (use NSAppearanceNameVibrantLight or NSAppearanceNameVibrantDark)
 */
@property (nonatomic, assign) NSAppearance *titlebarAppearance;

@end
