//
//  AppDelegate.m
//  DesktopPainterLogin
//
//  Created by GoKu on 18/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self quitAfterLaunchWrapperApp];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)quitAfterLaunchWrapperApp
{
    NSString *wrapperAppBundleID = [self wrapperAppBundleID];
    if (![self isAppRunning:wrapperAppBundleID]) {
        [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:wrapperAppBundleID
                                                             options:NSWorkspaceLaunchDefault
                                      additionalEventParamDescriptor:nil
                                                    launchIdentifier:NULL];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSApplication sharedApplication] terminate:self];
    });
}

- (NSString *)wrapperAppBundleID
{
    NSString *bundleID = nil;
    
    NSString *wrapperAppBundlePath = [NSBundle mainBundle].bundlePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSBundle *wrapperAppBundle = [NSBundle bundleWithPath:wrapperAppBundlePath];
    if (wrapperAppBundle) {
        bundleID = wrapperAppBundle.bundleIdentifier;
    }
    
    return bundleID;
}

- (BOOL)isAppRunning:(NSString *)appBundleID
{
    if (appBundleID.length > 0) {
        NSArray *runningApp = [NSRunningApplication runningApplicationsWithBundleIdentifier:appBundleID];
        if (runningApp.count > 0) {
            return YES;
        }
        return NO;
        
    } else {
        return NO;
    }
}

@end
