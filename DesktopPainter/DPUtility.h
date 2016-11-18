//
//  DPUtility.h
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPaintModeConfigKeyModeType     @"PaintModeConfigKeyModeType"
#define kPaintModeConfigKeyInterval     @"PaintModeConfigKeyInterval"

@interface DPUtility : NSObject

+ (void)createStorageDirIfNeeded;
+ (NSURL *)getStorageDirURL;

+ (NSArray *)getRandomImageURLOfCount:(NSUInteger)count;

+ (BOOL)setupLoginItem;
+ (BOOL)loginItemEnabled;
+ (void)setLoginItemEnabled:(BOOL)enabled;

+ (NSDictionary *)paintModeConfig;
+ (void)setPaintModeConfig:(NSDictionary *)config;

+ (NSArray *)intervalArraysToPaintRandom;

@end
