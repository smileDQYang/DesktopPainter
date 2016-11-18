//
//  AppDelegate.m
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "AppDelegate.h"
#import "DPPainter.h"
#import "DPUtility.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    [[DPPainter sharedPainter] paintWithModeConfig:[DPUtility paintModeConfig]];
    
    [DPUtility setupLoginItem];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
