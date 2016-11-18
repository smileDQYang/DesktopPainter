//
//  DPUtility.m
//  DesktopPainter
//
//  Created by GoKu on 17/11/2016.
//  Copyright © 2016 GoKuStudio. All rights reserved.
//

#import "DPUtility.h"
#import <ServiceManagement/ServiceManagement.h>

#define kLoginItemBundleID              @"com.gokustudio.DesktopPainterLogin"
#define kLoginItemEnabled               @"LoginItemEnabled"
#define kLoginItemEnabledDefaultValue   YES

@implementation DPUtility

+ (void)createStorageDirIfNeeded
{
    NSURL *storageDirURL = [DPUtility getStorageDirURL];
    NSLog(@"storage dir URL: %@", storageDirURL);

    BOOL isDir = NO;
    BOOL isExisted = [[NSFileManager defaultManager] fileExistsAtPath:storageDirURL.path isDirectory:&isDir];
    if (!isExisted || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtURL:storageDirURL
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:NULL];
    }
}

+ (NSURL *)getStorageDirURL
{
    NSURL *storageDirURL = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                                  inDomains:NSUserDomainMask].firstObject;
    storageDirURL = [storageDirURL URLByAppendingPathComponent:[NSBundle mainBundle].bundleIdentifier];
    storageDirURL = [storageDirURL URLByAppendingPathComponent:@"storage"];

    return storageDirURL;
}

+ (NSArray *)getRandomImageURLOfCount:(NSUInteger)count
{
    if (count <= 0) {
        return nil;
    }

    NSURL *storageDirURL = [DPUtility getStorageDirURL];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:storageDirURL
                                                      includingPropertiesForKeys:nil
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:NULL];
    NSLog(@"total image count: %ld", contents.count);
    if (contents.count <= 0) {
        return nil;
    }

    NSMutableArray *ret = [NSMutableArray array];
    NSMutableArray *tmpContents = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < count; ++i) {
        if (tmpContents.count <= 0) {
            [tmpContents addObjectsFromArray:contents];
        }

        NSUInteger random = arc4random() % tmpContents.count;
        [ret addObject:tmpContents[random]];
        [tmpContents removeObjectAtIndex:random];
    }

    if (ret.count != count) {
        return nil;
    }

    return ret;
}

+ (BOOL)setupLoginItem
{
    BOOL enabled = [DPUtility loginItemEnabled];
    BOOL ret = SMLoginItemSetEnabled((__bridge CFStringRef)kLoginItemBundleID, enabled);
    NSLog(@"login item enabled: %d, setup: %d", enabled, ret);
    return ret;
}

+ (BOOL)loginItemEnabled
{
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginItemEnabled];
    return (value ? [value boolValue] : kLoginItemEnabledDefaultValue);
}

+ (void)setLoginItemEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kLoginItemEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
