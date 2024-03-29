//
//  DPPainter.m
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "DPPainter.h"
#import "DPImageDownloader.h"
#import "DPUtility.h"
#import "DPConstants.h"

#define kPaintDayByDayMinutesInterval           60
#define kPaintRandomByMinutesMinimumValue       5

@interface DPPainter ()

@property (nonatomic, assign) DPPaintModeType   paintMode;

@property (nonatomic, strong) dispatch_source_t timerDayByDay;
@property (nonatomic, strong) dispatch_source_t timerWithInterval;

@end

@implementation DPPainter

+ (instancetype)sharedPainter
{
    static DPPainter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DPPainter alloc] init];

        [DPUtility createStorageDirIfNeeded];
    });
    return sharedInstance;
}

- (void)paintAutomatically
{
    [self paintWithModeConfig:[DPUtility paintModeConfig]];
}

- (void)paintWithModeConfig:(NSDictionary *)config
{
    NSLog(@"mode: %@, interval: %@", config[kPaintModeConfigKeyModeType], config[kPaintModeConfigKeyInterval]);
    
    switch ([config[kPaintModeConfigKeyModeType] unsignedIntegerValue]) {
        case kPaintModeRandom:
        {
            NSUInteger index = [config[kPaintModeConfigKeyInterval] unsignedIntegerValue];
            NSNumber *interval = (index < [DPUtility intervalArraysToPaintRandom].count) ? [DPUtility intervalArraysToPaintRandom][index] : [DPUtility intervalArraysToPaintRandom].firstObject;
            [self paintRandomByMinutes:[interval unsignedIntegerValue]];
        }
            break;
            
        case kPaintModeDayByDay:
        default:
        {
            [self paintDayByDay];
        }
            break;
    }
}

- (void)paintDayByDay
{
    [self resetTimer];

    self.timerDayByDay = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    dispatch_source_set_timer(self.timerDayByDay, DISPATCH_TIME_NOW, kPaintDayByDayMinutesInterval * 60 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timerDayByDay, ^{
        [self paintDayByDayAction];
    });
    dispatch_resume(self.timerDayByDay);
}

- (void)paintRandomByMinutes:(NSUInteger)minutes;
{
    NSUInteger interval = minutes;
    if (interval < kPaintRandomByMinutesMinimumValue) {
        interval = kPaintRandomByMinutesMinimumValue;
    }
    
    [self resetTimer];
    
    self.timerWithInterval = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    dispatch_source_set_timer(self.timerWithInterval, DISPATCH_TIME_NOW, interval * 60 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timerWithInterval, ^{
        [self paintRandomAction];
    });
    dispatch_resume(self.timerWithInterval);
}

- (void)paintDayByDayAction
{
    self.paintMode = kPaintModeDayByDay;
    
    [[DPImageDownloader sharedImageDownloader] fetchTodayImageWithCompletionHandler:^(NSError *error, NSURL *downloadedImageURL) {
        if (self.paintMode != kPaintModeDayByDay) {
            return;
        }
        
        if (error || !downloadedImageURL) {
            NSLog(@"error: %@", error);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSScreen *screen in [NSScreen screens]) {
                [[NSWorkspace sharedWorkspace] setDesktopImageURL:downloadedImageURL
                                                        forScreen:screen
                                                          options:@{NSWorkspaceDesktopImageScalingKey: @(NSImageScaleAxesIndependently)}
                                                            error:NULL];
            }
            NSLog(@"desktop image painted");
        });
    }];
}

- (void)paintRandomAction
{
    self.paintMode = kPaintModeRandom;
    
    [[DPImageDownloader sharedImageDownloader] batchFetchImagesWithCompletionHandler:^(NSError *error, NSArray *downloadedImageURLs) {
        if (self.paintMode != kPaintModeRandom) {
            return;
        }
        
        if (error || !downloadedImageURLs) {
            NSLog(@"error: %@", error);
            return;
        }
        
        NSArray *screens = [NSScreen screens];
        NSArray *images = [DPUtility getRandomImageURLOfCount:screens.count];
        
        if (images.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSUInteger i = 0; i < screens.count; ++i) {
                    NSLog(@"paint screen %ld with image: %@", i, images[i]);
                    [[NSWorkspace sharedWorkspace] setDesktopImageURL:images[i]
                                                            forScreen:screens[i]
                                                              options:@{NSWorkspaceDesktopImageScalingKey: @(NSImageScaleAxesIndependently)}
                                                                error:NULL];
                }
            });
        }
    }];
}

- (void)resetTimer
{
    if (self.timerDayByDay) {
        dispatch_source_cancel(self.timerDayByDay);
    }
    if (self.timerWithInterval) {
        dispatch_source_cancel(self.timerWithInterval);
    }
}

@end
