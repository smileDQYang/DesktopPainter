//
//  DPStatusBarController.m
//  DesktopPainter
//
//  Created by GoKu on 18/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "DPStatusBarController.h"
#import "DPSettingsWindowController.h"

@interface DPStatusBarController ()

@property (nonatomic, strong) DPSettingsWindowController *settingsWindowController;

@property (nonatomic, strong) NSStatusItem  *statusItem;

@property (strong) IBOutlet NSMenu          *statusBarMenu;
@property (weak) IBOutlet NSMenuItem        *menuItemSettings;
@property (weak) IBOutlet NSMenuItem        *menuItemQuit;

@end

@implementation DPStatusBarController

+ (instancetype)sharedController
{
    static DPStatusBarController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DPStatusBarController alloc] init];
        sharedInstance.view.hidden = YES;
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super initWithNibName:@"DPStatusBarController" bundle:nil];
    if (self) {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.statusItem.toolTip = @"DesktopPainter";
//    self.statusItem.title = self.statusItem.toolTip;
    self.statusItem.image = [NSImage imageNamed:@"StatusBar"];
    [self.statusItem.image setTemplate:YES];
    self.statusItem.menu = self.statusBarMenu;
}

- (IBAction)clickMenuItemSettings:(id)sender {
    if (!self.settingsWindowController) {
        self.settingsWindowController = [[DPSettingsWindowController alloc] init];
    }
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self.settingsWindowController showWindow:self];
}

- (IBAction)clickMenuItemQuit:(id)sender {
    [[NSRunningApplication currentApplication] terminate];
}

@end
