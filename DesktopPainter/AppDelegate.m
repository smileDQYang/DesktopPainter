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
#import "DPStatusBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    [DPUtility setupLoginItem];
    
    [DPStatusBarController sharedController];
    
    [[DPPainter sharedPainter] paintAutomatically];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
