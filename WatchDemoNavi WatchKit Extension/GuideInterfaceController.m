//
//  GuideInterfaceController.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/12.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "GuideInterfaceController.h"

#import <AMapNaviKit/AMapNaviCommonObj.h>
#import "CommonDefine.h"
#import "GuideTableRow.h"

#import "MMWormhole.h"
#import "FileTransiting.h"

@interface GuideInterfaceController ()
{
    NSArray *_guideList;
}

@property (nonatomic, strong) MMWormhole *wormhole;

@property (nonatomic, weak) IBOutlet WKInterfaceTable *guideTable;

@end

@implementation GuideInterfaceController

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
}

- (void)willActivate
{
    [super willActivate];
    
    [self addListenerForMessage];
    
    [self checkNaviGuide];
}

- (void)didDeactivate
{
    [super didDeactivate];
    
    [self stopListenerForMessage];
}

#pragma mark - Initalization

- (void)initProperties
{
    _guideList = [[NSArray alloc] init];
    
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:AppGroupIdentifier
                                                         optionalDirectory:AppGroupDirectory];
    FileTransiting *fileTransiting = [[FileTransiting alloc] initWithApplicationGroupIdentifier:AppGroupIdentifier
                                                                              optionalDirectory:AppGroupDirectory];
    [self.wormhole setWormholeMessenger:fileTransiting];
}

#pragma mark - Handle Listener

- (void)addListenerForMessage
{
    __weak GuideInterfaceController *weakSelf = self;
    
    [self.wormhole listenForMessageWithIdentifier:MessageIdentifier_UpdateGuide listener:^(id messageObject) {
        [weakSelf receiveUpdateGuideMessage:messageObject];
    }];
}

- (void)stopListenerForMessage
{
    [self.wormhole stopListeningForMessageWithIdentifier:MessageIdentifier_UpdateGuide];
}

#pragma mark - Receive Message

- (void)receiveUpdateGuideMessage:(id)messageObject
{
    _guideList = [messageObject valueForKey:@"value"];
    
    [self configTableWithGuideList];
}

#pragma mark - Utility

- (void)checkNaviGuide
{
    [self.wormhole passMessageObject:@{@"value":@"getGuideList"} identifier:MessageIdentifier_WatchCheck];
}

#pragma mark - Table

- (void)configTableWithGuideList
{
    if (![_guideList count])
    {
        return;
    }
    
    [self.guideTable setNumberOfRows:[_guideList count] withRowType:@"GuideTableRow"];
    
    for (int i = 0; i < self.guideTable.numberOfRows; i++)
    {
        GuideTableRow *aRow = [self.guideTable rowControllerAtIndex:i];
        
        [aRow setGuideItem:[_guideList objectAtIndex:i]];
    }
}

@end



