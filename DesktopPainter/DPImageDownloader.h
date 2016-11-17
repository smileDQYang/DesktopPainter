//
//  DPImageDownloader.h
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DPImageDownloader : NSObject

+ (instancetype)sharedImageDownloader;

- (void)fetchTodayImageWithCompletionHandler:(void (^)(NSError *error, NSURL *downloadedImageURL))completionHandler;
- (void)batchFetchImagesWithCompletionHandler:(void (^)(NSError *error, NSArray *downloadedImageURLs))completionHandler;

@end
