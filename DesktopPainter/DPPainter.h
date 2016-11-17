//
//  DPPainter.h
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPaintDayByDayMinutesInterval           60
#define kPaintRandomByMinutesMinimumValue       1

@interface DPPainter : NSObject

+ (instancetype)sharedPainter;

- (void)paintDayByDay;
- (void)paintRandomByMinutes:(NSUInteger)minutes;

@end
