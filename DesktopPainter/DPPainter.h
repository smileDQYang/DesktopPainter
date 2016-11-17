//
//  DPPainter.h
//  DesktopPainter
//
//  Created by jacky on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPPainter : NSObject

+ (instancetype)sharedPainter;

- (void)paintDayByDay;
- (void)paintWithTimeInterval:(NSTimeInterval)timeInterval;

@end
