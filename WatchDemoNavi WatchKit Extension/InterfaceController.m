//
//  InterfaceController.m
//  WatchDemoNavi WatchKit Extension
//
//  Created by 刘博 on 15/6/12.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "InterfaceController.h"
#import "CommonDefine.h"

#import "MMWormhole.h"
#import "FileTransiting.h"

@interface InterfaceController()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, assign) BOOL isStartNavi;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *tipLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *button1;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *button2;

@end


@implementation InterfaceController

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
    
    [self setTitle:@"AMapNavi"];
    
    [self configUIElements];
    
    [self addListenerForMessage];
    
    [self checkIsStartNavi];
}

- (void)willActivate
{
    [super willActivate];
    
    [self.tipLabel setHidden:self.isStartNavi];
    [self.button1 setHidden:!self.isStartNavi];
    [self.button2 setHidden:!self.isStartNavi];
}

- (void)didDeactivate
{
    [super didDeactivate];
}

- (void)dealloc
{
    [self stopListenerForMessage];
}

#pragma mark - Initalization

- (void)initProperties
{
    self.isStartNavi = NO;
    
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:AppGroupIdentifier
                                                         optionalDirectory:AppGroupDirectory];
    FileTransiting *fileTransiting = [[FileTransiting alloc] initWithApplicationGroupIdentifier:AppGroupIdentifier
                                                                              optionalDirectory:AppGroupDirectory];
    [self.wormhole setWormholeMessenger:fileTransiting];
}

#pragma mark - Handle Views

- (void)configUIElements
{
    [self.tipLabel setText:@"请在手机端启动导航"];
    
    [self.button1 setTitle:@"进入导航"];
    [self.button1 setHidden:YES];
    
    [self.button2 setTitle:@"全程路况"];
    [self.button2 setHidden:YES];
}

#pragma mark - Handle Listener

- (void)addListenerForMessage
{
    __weak InterfaceController *weakSelf = self;
    
    [self.wormhole listenForMessageWithIdentifier:MessageIdentifier_ChangeNaviState listener:^(id messageObject) {
        [weakSelf receiveDidStartNaviMessage:messageObject];
    }];
}

- (void)stopListenerForMessage
{
    [self.wormhole stopListeningForMessageWithIdentifier:MessageIdentifier_ChangeNaviState];
}

#pragma mark - Receive Message

- (void)receiveDidStartNaviMessage:(id)messageObject
{
    NSDictionary *messageDic = (NSDictionary *)messageObject;
    self.isStartNavi = [[messageDic valueForKey:@"value"] boolValue];
    
    if (self.isStartNavi)
    {
        [self presentControllerWithNames:@[@"HUDInterfaceController",@"GuideInterfaceController"] contexts:nil];
    }
    else
    {
        [self dismissController];
    }
}

#pragma mark - Utility

- (void)checkIsStartNavi
{
    [self.wormhole passMessageObject:@{@"value":@"isStartNavi"} identifier:MessageIdentifier_WatchCheck];
}

#pragma mark - Button Action

- (IBAction)button1Action:(id)sender
{
    [self presentControllerWithNames:@[@"HUDInterfaceController",@"GuideInterfaceController"] contexts:nil];
}

- (IBAction)button2Action:(id)sender
{
    [self presentControllerWithName:@"RouteTrafficInterfaceController" context:nil];
}

@end


