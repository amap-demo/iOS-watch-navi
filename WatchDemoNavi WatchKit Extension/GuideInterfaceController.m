//
//  GuideInterfaceController.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/12.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "GuideInterfaceController.h"
#import "CommonDefine.h"
#import "GuideTableRow.h"
#import "ExtensionDelegate.h"
#import "SessionDelegate.h"

@interface GuideInterfaceController ()
{
    NSArray *_guideList;
}

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
    
}

- (void)dealloc {
    [self stopListenerForMessage];
}


#pragma mark - Initalization

- (void)initProperties
{
    _guideList = [[NSArray alloc] init];
}

#pragma mark - Handle Listener

- (void)addListenerForMessage
{
    __weak GuideInterfaceController *weakSelf = self;
    
    ExtensionDelegate *delegate = (ExtensionDelegate*)[WKExtension sharedExtension].delegate;
    [delegate.sessionDelegate setReceiveMsgBlock:^(NSDictionary<NSString *,id> * _Nonnull message) {
        NSString *identifier = [message objectForKey:MessageIdentifierKey];
        if ([identifier isEqualToString:MessageIdentifier_UpdateGuide]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf receiveUpdateGuideMessage:message];
            });
        }
    } withKey:NSStringFromClass(self.class)];
}

- (void)stopListenerForMessage
{
    ExtensionDelegate *delegate = (ExtensionDelegate *)[WKExtension sharedExtension].delegate;
    [delegate.sessionDelegate removeMsgBlockWithKey:NSStringFromClass(self.class)];
//    [self.wormhole stopListeningForMessageWithIdentifier:MessageIdentifier_UpdateGuide];
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
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_WatchCheck,@"value":@"getGuideList"} replyHandler:nil errorHandler:nil];
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



