//
//  DPPainter.m
//  DesktopPainter
//
//  Created by jacky on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "DPPainter.h"
#import "DPImageDownloader.h"

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
    });
    return sharedInstance;
}

- (void)paintDayByDay
{
    [[DPImageDownloader sharedImageDownloader] fetchTodayImageWithCompletionHandler:^(NSError *error, NSURL *imageURL) {
        
    }];
}

- (void)paintWithTimeInterval:(NSTimeInterval)timeInterval
{
    
}

@end
