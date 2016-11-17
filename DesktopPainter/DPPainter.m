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

@interface DPPainter ()

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

- (void)paintDayByDayAction
{
    [[DPImageDownloader sharedImageDownloader] fetchTodayImageWithCompletionHandler:^(NSError *error, NSURL *downloadedImageURL) {
        if (!error && downloadedImageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSScreen *screen in [NSScreen screens]) {
                    [[NSWorkspace sharedWorkspace] setDesktopImageURL:downloadedImageURL
                                                            forScreen:screen
                                                              options:@{NSWorkspaceDesktopImageScalingKey: @(NSImageScaleAxesIndependently)}
                                                                error:NULL];
                }
                NSLog(@"desktop image painted");
            });

        } else {
            NSLog(@"error: %@", error);
        }
    }];
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

- (void)paintRandomAction
{
    [[DPImageDownloader sharedImageDownloader] batchFetchImagesWithCompletionHandler:^(NSError *error, NSArray *downloadedImageURLs) {
        NSArray *screens = [NSScreen screens];
        NSArray *images = [DPUtility getRandomImageURLOfCount:screens.count];

        if (images.count > 0) {
            for (NSUInteger i = 0; i < screens.count; ++i) {
                NSLog(@"paint screen %ld with image: %@", i, images[i]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSWorkspace sharedWorkspace] setDesktopImageURL:images[i]
                                                            forScreen:screens[i]
                                                              options:@{NSWorkspaceDesktopImageScalingKey: @(NSImageScaleAxesIndependently)}
                                                                error:NULL];
                });
            }
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
