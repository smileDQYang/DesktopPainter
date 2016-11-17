//
//  AppDelegate.m
//  DesktopPainter
//
//  Created by jacky on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "AppDelegate.h"
#import "DPPainter.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [[DPPainter sharedPainter] paintDayByDay];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
