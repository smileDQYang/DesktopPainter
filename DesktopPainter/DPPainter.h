//
//  DPPainter.h
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DPPainter : NSObject

+ (instancetype)sharedPainter;

- (void)paintWithModeConfig:(NSDictionary *)config;

@end
