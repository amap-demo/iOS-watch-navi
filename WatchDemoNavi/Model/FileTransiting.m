//
//  FileTransiting.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/17.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "FileTransiting.h"
#import <AMapNaviKit/AMapNaviInfo.h>

@implementation FileTransiting

#pragma mark - Override

- (BOOL)writeMessageObject:(id<NSCoding>)messageObject forIdentifier:(NSString *)identifier
{
    if (identifier == nil)
    {
        return NO;
    }
    
    if (messageObject)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
        NSString *filePath = [self filePathForIdentifier:identifier];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        if (data == nil || filePath == nil || fileURL == nil)
        {
            return NO;
        }
        
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        NSError *error = nil;
        __block NSError *error2 = nil;
        __block BOOL success = NO;
        
        [fileCoordinator coordinateWritingItemAtURL:fileURL
                                            options:0
                                              error:&error
                                         byAccessor:^(NSURL *newURL) {
                 success = [data writeToURL:newURL
                                    options:NSDataWritingFileProtectionCompleteUntilFirstUserAuthentication|NSDataWritingAtomic
                                      error:&error2];
                                         }];
        
        if (!success)
        {
            return NO;
        }
    }
    
    return YES;
}

- (id<NSCoding>)messageObjectForIdentifier:(NSString *)identifier
{
    if (identifier == nil)
    {
        return nil;
    }
    
    NSString *filePath = [self filePathForIdentifier:identifier];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (filePath == nil || fileURL == nil)
    {
        return nil;
    }
    
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    __block NSData *data = nil;
    
    [fileCoordinator coordinateReadingItemAtURL:fileURL
                                        options:0
                                          error:&error
                                     byAccessor:^(NSURL *newURL) {
                                         data = [NSData dataWithContentsOfURL:newURL];
                                     }];
    
    if (data == nil)
    {
        return nil;
    }
    
    [NSKeyedUnarchiver setClass:[AMapNaviInfo class] forClassName:@"AMapNaviInfo"];
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return messageObject;
}

@end
