//
//  RouteTrafficInterfaceController.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/16.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "RouteTrafficInterfaceController.h"

#import "CommonDefine.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "ExtensionDelegate.h"
#import "SessionDelegate.h"

@interface RouteTrafficInterfaceController ()
{
    UIImage *_trafficImage;
}

@property (nonatomic, weak) IBOutlet WKInterfaceImage *trafficCircleImage;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *tipLabel;

@end

@implementation RouteTrafficInterfaceController

- (instancetype)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    [self.tipLabel setText:@"全程路况"];
    [self.trafficCircleImage setWidth:120];
    [self.trafficCircleImage setHeight:120];
}

- (void)willActivate
{
    [super willActivate];
    
    [self addListenerForMessage];
    
    [self checkTrafficImage];
}

- (void)didDeactivate
{
    [super didDeactivate];
}

- (void)dealloc {
    [self stopListenerForMessage];
}

#pragma mark - Handle Listener

- (void)addListenerForMessage
{
    __weak RouteTrafficInterfaceController *weakSelf = self;
    
    ExtensionDelegate *delegate = (ExtensionDelegate *)[WKExtension sharedExtension].delegate;
    [delegate.sessionDelegate setReceiveMsgBlock:^(NSDictionary<NSString *,id> * _Nonnull message) {
        NSString *identifier = [message objectForKey:MessageIdentifierKey];
        if ([identifier isEqualToString:MessageIdentifier_TrafficImage]) {
            [weakSelf receiveTrafficImageMessage:message];
        }
    } withKey:NSStringFromClass(self.class)];
}

- (void)stopListenerForMessage
{
    ExtensionDelegate *delegate = (ExtensionDelegate *)[WKExtension sharedExtension].delegate;
    [delegate.sessionDelegate removeMsgBlockWithKey:NSStringFromClass(self.class)];
}

#pragma mark - Receive Message

- (void)receiveTrafficImageMessage:(id)messageObject
{
    NSData *imageData = [messageObject valueForKey:@"value"];
    UIImage *image = [UIImage imageWithData:imageData];
    [self setTrafficImage:image];
}

#pragma mark - Utility

- (void)checkTrafficImage
{
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_WatchCheck,@"value":@"getTrafficImage"} replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"watch check getTraffic image error:%@",error);
    }];
}

#pragma mark - Override

- (void)setTrafficImage:(UIImage *)image
{
    if (image == nil)
    {
        return;
    }
    
    _trafficImage = image;
    
    [self.trafficCircleImage setImage:_trafficImage];
}

@end
