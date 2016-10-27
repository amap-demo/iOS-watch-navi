//
//  HUDInterfaceController.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/12.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "HUDInterfaceController.h"

#import <AMapNaviKit/AMapNaviInfo.h>
#import "CommonDefine.h"

#import "MMWormhole.h"
#import "FileTransiting.h"

@interface HUDInterfaceController ()

@property (nonatomic, strong) MMWormhole *wormhole;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *currentRoadLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *nextRoadLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *remainDistanceLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *routeRemainInfo;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *turnIcon;

@end

@implementation HUDInterfaceController

#pragma mark - Life Cycle

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
    
    [self addStopNaviMenuItem];
    
    [self.turnIcon setWidth:50];
    [self.turnIcon setHeight:50];
}

- (void)willActivate
{
    [super willActivate];
    
    [self addListenerForMessage];
    
    [self checkNaviInfo];
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

- (void)addStopNaviMenuItem
{
    [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"停止导航" action:@selector(stopNaviMenuItemAction)];
}

#pragma mark - Menu Action

- (IBAction)stopNaviMenuItemAction
{
    if (self.wormhole)
    {
        [self.wormhole passMessageObject:nil identifier:MessageIdentifier_WatchStopNavi];
    }
}

#pragma mark - Handle Listener

- (void)addListenerForMessage
{
    __weak HUDInterfaceController *weakSelf = self;
    
    [self.wormhole listenForMessageWithIdentifier:MessageIdentifier_UpdateNaviInfo listener:^(id messageObject) {
        [weakSelf receiveUpdateNaviInfoMessage:messageObject];
    }];
}

- (void)stopListenerForMessage
{
    [self.wormhole stopListeningForMessageWithIdentifier:MessageIdentifier_UpdateNaviInfo];
}

#pragma mark - Receive Message

- (void)receiveUpdateNaviInfoMessage:(id)messageObject
{
    AMapNaviInfo *naviInfo = [(NSDictionary *)messageObject valueForKey:@"value"];
    
    if (naviInfo)
    {
        [self.currentRoadLabel setText:[NSString stringWithFormat:@"从 %@ 进入", naviInfo.currentRoadName]];
        [self.nextRoadLabel setText:naviInfo.nextRoadName];
        
        [self.turnIcon setImageNamed:[self buildImageNameWithIconType:naviInfo.iconType]];
        [self.remainDistanceLabel setText:[self normalizedRemainDistance:naviInfo.segmentRemainDistance]];
        
        NSString *roadRemainDistance = [self normalizedRemainDistance:naviInfo.routeRemainDistance];
        NSString *roadRemainTime = [self normalizedRemainTime:naviInfo.routeRemainTime];
        [self.routeRemainInfo setText:[NSString stringWithFormat:@"%@ | %@", roadRemainTime, roadRemainDistance]];
    }
}

#pragma mark - Utility

- (void)checkNaviInfo
{
    [self.wormhole passMessageObject:@{@"value":@"getNaviInfo"} identifier:MessageIdentifier_WatchCheck];
}

- (NSString *)buildImageNameWithIconType:(NSInteger)iconType
{
    return [NSString stringWithFormat:@"default_navi_hud_%ld", (long)iconType];
}

- (NSString *)normalizedRemainDistance:(NSInteger)remainDistance
{
    if (remainDistance < 0)
    {
        return nil;
    }
    
    if (remainDistance >= 1000)
    {
        CGFloat kiloMeter = remainDistance / 1000.0;
        
        if (remainDistance % 1000 >= 100)
        {
            kiloMeter -= 0.05f;
            return [NSString stringWithFormat:@"%.1f公里", kiloMeter];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f公里", kiloMeter];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%ld米", (long)remainDistance];
    }
}

- (NSString *)normalizedRemainTime:(NSInteger)remainTime
{
    if (remainTime < 0)
    {
        return nil;
    }
    
    if (remainTime < 60)
    {
        return [NSString stringWithFormat:@"< 1分钟"];
    }
    else if (remainTime >= 60 && remainTime < 60*60)
    {
        return [NSString stringWithFormat:@"%ld分钟", (long)remainTime/60];
    }
    else
    {
        NSInteger hours = remainTime / 60 / 60;
        NSInteger minute = remainTime / 60 % 60;
        if (minute == 0)
        {
            return [NSString stringWithFormat:@"%ld小时", (long)hours];
        }
        else
        {
            return [NSString stringWithFormat:@"%ld小时%ld分钟", (long)hours, (long)minute];
        }
    }
}

@end



