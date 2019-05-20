//
//  ExtensionDelegate.h
//  WatchDemoNavi WatchKit Extension
//
//  Created by lly on 2019/5/14.
//  Copyright © 2019 lly. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@class SessionDelegate;

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>

@property (nonatomic,strong) SessionDelegate *sessionDelegate;

@end
