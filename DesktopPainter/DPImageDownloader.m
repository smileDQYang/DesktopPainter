//
//  DPImageDownloader.m
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "DPImageDownloader.h"
#import "DPUtility.h"

#define kFetchTimeout           60

#define kImageURLPrefixBing     @"Bing."
#define kFetchURLBing           @"http://www.bing.com/HPImageArchive.aspx?format=js&idx=%d&n=%d"

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

- (void)fetchTodayImageWithCompletionHandler:(void (^)(NSError *error, NSURL *downloadedImageURL))completionHandler
{
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:kFetchURLBing, 0, 1]];
    NSLog(@"fetch URL: %@", fetchURL);

    NSURLRequest *request = [NSURLRequest requestWithURL:fetchURL];
    [[self.session dataTaskWithRequest:request
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        NSHTTPURLResponse *ret = (NSHTTPURLResponse *)response;
                        NSLog(@"error: %@, status code: %ld", error, ret.statusCode);

                        NSDictionary *json = nil;
                        if (!error && (ret.statusCode == 200) &&
                            (json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL])) {

                            NSArray *imageList = json[@"images"];
                            NSDictionary *imageInfo = imageList.firstObject;
                            NSString *urlString = imageInfo[@"url"];
                            NSLog(@"image download URL: %@", urlString);

                            if (urlString) {
                                NSString *imageName = [kImageURLPrefixBing stringByAppendingString:[urlString lastPathComponent]];
                                NSURL *storageURL = [[DPUtility getStorageDirURL] URLByAppendingPathComponent:imageName];
                                NSLog(@"image storage URL: %@", storageURL);

                                if ([[NSFileManager defaultManager] fileExistsAtPath:storageURL.path]) {
                                    NSLog(@"image already downloaded");
                                    completionHandler(nil, storageURL);

                                } else {
                                    [[self.session downloadTaskWithURL:[NSURL URLWithString:urlString]
                                                     completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                         NSHTTPURLResponse *ret = (NSHTTPURLResponse *)response;
                                                         NSLog(@"error: %@, status code: %ld", error, ret.statusCode);

                                                         if (!error && (ret.statusCode == 200)) {
                                                             [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                     toURL:storageURL
                                                                                                     error:NULL];
                                                             completionHandler(nil, storageURL);

                                                         } else {
                                                             NSError *error = [NSError errorWithDomain:@"DesktopPainter.Fetch" code:0 userInfo:nil];
                                                             completionHandler(error, nil);
                                                         }
                                                         
                                                     }] resume];
                                }

                            } else {
                                NSError *error = [NSError errorWithDomain:@"DesktopPainter.Fetch" code:0 userInfo:nil];
                                completionHandler(error, nil);
                            }

                        } else {
                            NSError *error = [NSError errorWithDomain:@"DesktopPainter.Fetch" code:0 userInfo:nil];
                            completionHandler(error, nil);
                        }
                        
                    }] resume];
}

- (void)batchFetchImagesWithCompletionHandler:(void (^)(NSError *error, NSArray *downloadedImageURLs))completionHandler
{
    NSMutableArray *downloadedImageURLs = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i <= 20; ++i) {
        dispatch_group_enter(group);

        NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:kFetchURLBing, i, 1]];
        NSLog(@"fetch URL: %@", fetchURL);

        NSURLRequest *request = [NSURLRequest requestWithURL:fetchURL];
        [[self.session dataTaskWithRequest:request
                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                             NSHTTPURLResponse *ret = (NSHTTPURLResponse *)response;
                             NSLog(@"error: %@, status code: %ld", error, ret.statusCode);

                             NSDictionary *json = nil;
                             if (!error && (ret.statusCode == 200) &&
                                 (json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL])) {

                                 NSArray *imageList = json[@"images"];
                                 NSDictionary *imageInfo = imageList.firstObject;
                                 NSString *urlString = imageInfo[@"url"];
                                 NSLog(@"image download URL: %@", urlString);

                                 if (urlString) {
                                     NSString *imageName = [kImageURLPrefixBing stringByAppendingString:[urlString lastPathComponent]];
                                     NSURL *storageURL = [[DPUtility getStorageDirURL] URLByAppendingPathComponent:imageName];
                                     NSLog(@"image storage URL: %@", storageURL);

                                     if ([[NSFileManager defaultManager] fileExistsAtPath:storageURL.path]) {
                                         NSLog(@"image already downloaded");
                                         [downloadedImageURLs addObject:storageURL];
                                         dispatch_group_leave(group);

                                     } else {
                                         [[self.session downloadTaskWithURL:[NSURL URLWithString:urlString]
                                                          completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                              NSHTTPURLResponse *ret = (NSHTTPURLResponse *)response;
                                                              NSLog(@"error: %@, status code: %ld", error, ret.statusCode);

                                                              if (!error && (ret.statusCode == 200)) {
                                                                  [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                          toURL:storageURL
                                                                                                          error:NULL];
                                                                  [downloadedImageURLs addObject:storageURL];
                                                                  dispatch_group_leave(group);

                                                              } else {
                                                                  dispatch_group_leave(group);
                                                              }

                                                          }] resume];
                                     }

                                 } else {
                                     dispatch_group_leave(group);
                                 }
                                 
                             } else {
                                 dispatch_group_leave(group);
                             }
                             
                         }] resume];
    }

    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, kFetchTimeout * NSEC_PER_SEC));
    completionHandler(nil, downloadedImageURLs);
}

@end
