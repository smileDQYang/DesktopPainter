//
//  DPPainter.h
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPConstants.h"

@interface DPPainter : NSObject

+ (instancetype)sharedPainter;

- (void)paintWithMode:(DPPaintModeType)mode intervalByMinutes:(NSUInteger)intervalByMinutes;

@end
