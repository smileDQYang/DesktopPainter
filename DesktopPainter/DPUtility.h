//
//  DPUtility.h
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPUtility : NSObject

+ (void)createStorageDirIfNeeded;
+ (NSURL *)getStorageDirURL;

+ (NSArray *)getRandomImageURLOfCount:(NSUInteger)count;

+ (BOOL)setupLoginItem;
+ (BOOL)loginItemEnabled;
+ (void)setLoginItemEnabled:(BOOL)enabled;

@end
