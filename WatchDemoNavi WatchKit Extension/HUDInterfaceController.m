//
//  HUDInterfaceController.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/12.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "HUDInterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "ExtensionDelegate.h"
#import "SessionDelegate.h"
#import "CommonDefine.h"

@interface HUDInterfaceController ()

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

- (void)addStopNaviMenuItem
{
    [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"停止导航" action:@selector(stopNaviMenuItemAction)];
}

#pragma mark - Menu Action

- (IBAction)stopNaviMenuItemAction
{
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_WatchStopNavi} replyHandler:nil errorHandler:nil];
}

#pragma mark - Handle Listener

- (void)addListenerForMessage
{
    __weak HUDInterfaceController *weakSelf = self;
    
    ExtensionDelegate *delegate = (ExtensionDelegate*)[WKExtension sharedExtension].delegate;
    [delegate.sessionDelegate setReceiveMsgBlock:^(NSDictionary<NSString *,id> * _Nonnull message) {
        NSString *identifier = [message objectForKey:MessageIdentifierKey];
        if ([identifier isEqualToString:MessageIdentifier_UpdateNaviInfo]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf receiveUpdateNaviInfoMessage:message];
            });
        }
    } withKey:NSStringFromClass(self.class)];
}

- (void)stopListenerForMessage
{
    ExtensionDelegate *delegate = (ExtensionDelegate*)[WKExtension sharedExtension].delegate;
    [delegate.sessionDelegate removeMsgBlockWithKey:NSStringFromClass(self.class)];
}

#pragma mark - Receive Message

- (void)receiveUpdateNaviInfoMessage:(NSDictionary *)message
{
    NSDictionary *naviDict = [message valueForKey:@"value"];
    
    if (naviDict)
    {
        [self.currentRoadLabel setText:[NSString stringWithFormat:@"从 %@ 进入", [naviDict objectForKey:@"currentRoadName"]]];
        [self.nextRoadLabel setText:[naviDict objectForKey:@"nextRoadName"]];
        
        [self.turnIcon setImageNamed:[self buildImageNameWithIconType:[[naviDict objectForKey:@"iconType"] integerValue]]];
        [self.remainDistanceLabel setText:[self normalizedRemainDistance:[[naviDict objectForKey:@"segmentRemainDistance"] integerValue]]];
        
        NSString *roadRemainDistance = [self normalizedRemainDistance:[[naviDict objectForKey:@"routeRemainDistance"] integerValue]];
        NSString *roadRemainTime = [self normalizedRemainTime:[[naviDict objectForKey:@"routeRemainTime"] integerValue]];
        [self.routeRemainInfo setText:[NSString stringWithFormat:@"%@ | %@", roadRemainTime, roadRemainDistance]];
    }
}

#pragma mark - Utility

- (void)checkNaviInfo
{
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_WatchCheck,@"value":@"getNaviInfo"} replyHandler:nil errorHandler:nil];
//    [self.wormhole passMessageObject:@{@"value":@"getNaviInfo"} identifier:MessageIdentifier_WatchCheck];
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



