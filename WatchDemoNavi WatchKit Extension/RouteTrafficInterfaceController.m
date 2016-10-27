//
//  RouteTrafficInterfaceController.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/16.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "RouteTrafficInterfaceController.h"

#import "CommonDefine.h"

#import "MMWormhole.h"
#import "FileTransiting.h"

@interface RouteTrafficInterfaceController ()
{
    UIImage *_trafficImage;
}

@property (nonatomic, strong) MMWormhole *wormhole;

@property (nonatomic, weak) IBOutlet WKInterfaceImage *trafficCircleImage;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *tipLabel;

@end

@implementation RouteTrafficInterfaceController

- (instancetype)init
{
    if (self = [super init])
    {
        [self initProperties];
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
    
    [self stopListenerForMessage];
}

#pragma mark - Initalization

- (void)initProperties
{
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:AppGroupIdentifier
                                                         optionalDirectory:AppGroupDirectory];
    FileTransiting *fileTransiting = [[FileTransiting alloc] initWithApplicationGroupIdentifier:AppGroupIdentifier
                                                                              optionalDirectory:AppGroupDirectory];
    [self.wormhole setWormholeMessenger:fileTransiting];
}

#pragma mark - Handle Listener

- (void)addListenerForMessage
{
    __weak RouteTrafficInterfaceController *weakSelf = self;
    
    [self.wormhole listenForMessageWithIdentifier:MessageIdentifier_TrafficImage listener:^(id messageObject) {
        [weakSelf receiveTrafficImageMessage:messageObject];
    }];
}

- (void)stopListenerForMessage
{
    [self.wormhole stopListeningForMessageWithIdentifier:MessageIdentifier_TrafficImage];
}

#pragma mark - Receive Message

- (void)receiveTrafficImageMessage:(id)messageObject
{
    [self setTrafficImage:[messageObject valueForKey:@"value"]];
}

#pragma mark - Utility

- (void)checkTrafficImage
{
    [self.wormhole passMessageObject:@{@"value":@"getTrafficImage"} identifier:MessageIdentifier_WatchCheck];
}

#pragma mark - Override

- (void)setTrafficImage:(UIImage *)image
{
    if (image == nil)
    {
        return;
    }
    
    _trafficImage = image;
    
    [[WKInterfaceDevice currentDevice] removeCachedImageWithName:@"WatchNaviDemo_TrafficImage"];
    [[WKInterfaceDevice currentDevice] addCachedImage:image name:@"WatchNaviDemo_TrafficImage"];
    
    [self.trafficCircleImage setImageNamed:@"WatchNaviDemo_TrafficImage"];
}

@end
