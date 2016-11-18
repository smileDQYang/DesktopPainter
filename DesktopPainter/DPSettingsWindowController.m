//
//  DPSettingsWindowController.m
//  DesktopPainter
//
//  Created by jacky on 18/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "DPSettingsWindowController.h"
#import "DPUtility.h"
#import "DPConstants.h"
#import "DPPainter.h"

@interface DPSettingsWindowController ()

@property (weak) NSToolbarItem *lastSelectedToolbarItem;
@property (weak) IBOutlet NSToolbarItem *toolbarItemGeneral;
@property (weak) IBOutlet NSToolbarItem *toolbarItemApp;

@property (strong) IBOutlet NSView *settingGeneralView;
@property (weak) IBOutlet NSButton *chooseModeDayByDay;
@property (weak) IBOutlet NSButton *chooseModeRandom;
@property (weak) IBOutlet NSView *randomDetailedView;
@property (weak) IBOutlet NSPopUpButton *randomInterval;

@property (strong) IBOutlet NSView *settingAppView;
@property (weak) IBOutlet NSButton *checkLoginItem;

@end

@implementation DPSettingsWindowController

- (instancetype)init {
    self = [super initWithWindowNibName:@"DPSettingsWindowController"];
    if (self) {
    }
    return self;
}

- (void)windowDidLoad
{
    self.lastSelectedToolbarItem = nil;
    
    self.window.toolbar.selectedItemIdentifier = self.toolbarItemGeneral.itemIdentifier;
    [self clickTabSettingGeneral:self.toolbarItemGeneral];
}

- (IBAction)clickTabSettingGeneral:(id)sender {
    if (self.lastSelectedToolbarItem != sender) {
        NSDictionary *config = [DPUtility paintModeConfig];
        switch ([config[kPaintModeConfigKeyModeType] unsignedIntegerValue]) {
            case kPaintModeRandom:
            {
                self.chooseModeDayByDay.state = NSOffState;
                self.chooseModeRandom.state = NSOnState;
                self.randomDetailedView.hidden = NO;
            }
                break;
                
            case kPaintModeDayByDay:
            default:
            {
                self.chooseModeDayByDay.state = NSOnState;
                self.chooseModeRandom.state = NSOffState;
                self.randomDetailedView.hidden = YES;
            }
                break;
        }
        NSUInteger index = [config[kPaintModeConfigKeyInterval] unsignedIntegerValue];
        if (index >= self.randomInterval.numberOfItems) {
            index = 0;
        }
        [self.randomInterval selectItemAtIndex:index];
        
        [self switchToTabView:self.settingGeneralView withAnimation:YES];
    }
    
    self.lastSelectedToolbarItem = sender;
}

- (IBAction)clickTabSettingApp:(id)sender {
    if (self.lastSelectedToolbarItem != sender) {
        self.checkLoginItem.state = [DPUtility loginItemEnabled] ? NSOnState : NSOffState;
        [self switchToTabView:self.settingAppView withAnimation:YES];
    }
    
    self.lastSelectedToolbarItem = sender;
}

- (void)switchToTabView:(NSView *)settingView withAnimation:(BOOL)animation
{
    NSView *windowView = self.window.contentView;
    for (NSView *view in windowView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat oldHeight = windowView.frame.size.height;
    CGFloat oldWidth = windowView.frame.size.width;
    
    [windowView addSubview:settingView];
    CGFloat newHeight = settingView.frame.size.height;
    CGFloat newWidth = settingView.frame.size.width;
    
    CGFloat deltaHeight = newHeight - oldHeight;
    CGFloat deltaWidth = newWidth - oldWidth;
    
    NSPoint origin = settingView.frame.origin;
    origin.y -= deltaHeight;
    // no need to change for origin.x
    // because the default NSAutoresizingMaskOptions of settingView is: NSViewMaxXMargin + NSViewMinYMargin
    // that means: MinX is fixed, MaxY is fixed.
    [settingView setFrameOrigin:origin];
    
    NSRect frame = self.window.frame;
    frame.size.height += deltaHeight;
    frame.origin.y -= deltaHeight;
    frame.size.width += deltaWidth;
    [self.window setFrame:frame display:YES animate:animation];
}

- (IBAction)clickChooseModeDayByDay:(id)sender {
    self.chooseModeDayByDay.state = NSOnState;
    self.chooseModeRandom.state = NSOffState;
    self.randomDetailedView.hidden = YES;

    NSDictionary *config = [DPUtility paintModeConfig];
    [DPUtility setPaintModeConfig:@{kPaintModeConfigKeyModeType: @(kPaintModeDayByDay),
                                    kPaintModeConfigKeyInterval: config[kPaintModeConfigKeyInterval]}];
    [[DPPainter sharedPainter] paintAutomatically];
}

- (IBAction)clickChooseModeRandom:(id)sender {
    self.chooseModeDayByDay.state = NSOffState;
    self.chooseModeRandom.state = NSOnState;
    self.randomDetailedView.hidden = NO;
    
    NSDictionary *config = [DPUtility paintModeConfig];
    [DPUtility setPaintModeConfig:@{kPaintModeConfigKeyModeType: @(kPaintModeRandom),
                                    kPaintModeConfigKeyInterval: config[kPaintModeConfigKeyInterval]}];
    [[DPPainter sharedPainter] paintAutomatically];
}

- (IBAction)clickRandomInterval:(id)sender {
    NSUInteger index = self.randomInterval.indexOfSelectedItem;
    if (index >= [DPUtility intervalArraysToPaintRandom].count) {
        NSDictionary *config = [DPUtility paintModeConfig];
        index = [config[kPaintModeConfigKeyInterval] unsignedIntegerValue];
    }
    
    [DPUtility setPaintModeConfig:@{kPaintModeConfigKeyModeType: @(kPaintModeRandom),
                                    kPaintModeConfigKeyInterval: @(index)}];
    [[DPPainter sharedPainter] paintAutomatically];
}

- (IBAction)clickCheckLoginItem:(id)sender {
    NSInteger stateAfterClick = self.checkLoginItem.state;
    NSInteger stateBeforeClick = 1 - stateAfterClick;
    
    [DPUtility setLoginItemEnabled:(stateAfterClick == NSOnState)];
    BOOL ret = [DPUtility setupLoginItem];
    if (!ret) {
        self.checkLoginItem.state = stateBeforeClick;
        [DPUtility setLoginItemEnabled:(stateBeforeClick == NSOnState)];
    }
}

@end
