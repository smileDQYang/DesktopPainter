//
//  DPImageDownloader.m
//  DesktopPainter
//
//  Created by jacky on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#define kFetchURLFromBing       @"http://www.bing.com/HPImageArchive.aspx?format=js&idx=%d&n=%d"

#import "DPImageDownloader.h"

@interface DPImageDownloader ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation DPImageDownloader

+ (instancetype)sharedImageDownloader
{
    static DPImageDownloader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DPImageDownloader alloc] init];
        sharedInstance.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                               delegate:nil
                                                          delegateQueue:[[NSOperationQueue alloc] init]];
    });
    return sharedInstance;
}

- (void)fetchTodayImageWithCompletionHandler:(void (^)(NSError *error, NSURL *imageURL))completionHandler
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kFetchURLFromBing, 0, 1]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[self.session dataTaskWithRequest:request
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        NSHTTPURLResponse *ret = (NSHTTPURLResponse *)response;
                        NSLog(@"error: %@, status code: %ld", error, ret.statusCode);

                        if (!error && (ret.statusCode == 200)) {
                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:NULL];
                            if (json) {
                                NSArray *imageList = json[@"images"];
                                NSDictionary *imageInfo = imageList.firstObject;
                                NSString *urlString = imageInfo[@"url"];
                                NSLog(@"image url: %@", urlString);
                                NSString *imageName = [urlString lastPathComponent];
                                
                                if (urlString) {
                                    [[self.session downloadTaskWithURL:[NSURL URLWithString:urlString]
                                                    completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        NSHTTPURLResponse *ret = (NSHTTPURLResponse *)response;
                                                        NSLog(@"error: %@, status code: %ld", error, ret.statusCode);
                                                        
                                                        if (!error && (ret.statusCode == 200)) {
                                                            NSLog(@"location: %@", location);
                                                            NSURL *downloadURL = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory
                                                                                                                        inDomains:NSUserDomainMask].firstObject;
                                                            NSURL *storage = [downloadURL URLByAppendingPathComponent:imageName];
                                                            [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                    toURL:storage
                                                                                                    error:NULL];
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                for (NSScreen *screen in [NSScreen screens]) {
                                                                    [[NSWorkspace sharedWorkspace] setDesktopImageURL:storage
                                                                                                            forScreen:screen
                                                                                                              options:@{NSWorkspaceDesktopImageScalingKey: @(NSImageScaleAxesIndependently)}
                                                                                                                error:NULL];
                                                                }
                                                                NSLog(@"set desktop image done");
                                                            });
                                                        }
                                                        
                                                    }] resume];
                                }
                            }
                        }
                        
                    }] resume];
}

- (void)batchFetchImagesWithCompletionHandler:(void (^)(NSError *error, NSArray *images))completionHandler
{
    
}

@end
