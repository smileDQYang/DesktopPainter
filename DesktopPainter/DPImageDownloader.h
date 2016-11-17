//
//  DPImageDownloader.h
//  DesktopPainter
//
//  Created by jacky on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DPImageDownloader : NSObject

+ (instancetype)sharedImageDownloader;

- (void)fetchTodayImageWithCompletionHandler:(void (^)(NSError *error, NSURL *imageURL))completionHandler;
- (void)batchFetchImagesWithCompletionHandler:(void (^)(NSError *error, NSArray *images))completionHandler;

@end
