//
//  ViewController.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/11.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SpeechSynthesizer.h"

#import "CommonDefine.h"
#import "TrafficStatusCircle.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "AMapNaviInfo+ToDictionary.h"
#import "AppDelegate.h"
#import "SessionDelegate.h"
#import "AMapNaviGuide+ToDictionary.h"

@interface ViewController ()<AMapNaviDriveViewDelegate, AMapNaviDriveDataRepresentable>
{
    AMapNaviPoint *_endPoint;
    UILabel *_endPointLabel;
    UITapGestureRecognizer *_tapGesture;
    
    AMapNaviInfo *_savedNaviInfo;
    
    BOOL _isGPSNavi;
    BOOL _shouleSendNotification;
}

@property (nonatomic, strong) AMapNaviDriveView *driveView;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.sessionDelegate setReceiveMsgBlock:^(NSDictionary<NSString *,id> * _Nonnull message) {
        [self handleReceivedMsg:message];
    } withKey:NSStringFromClass(self.class)];
    
    [self initProperties];
    
    [self initPoints];
    
    [self initNaviManager];
    
    [self configSubViews];
}

- (void)dealloc
{
    [self stopListenerForMessage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initMapView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAppWillResignActive) name:@"AppWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAppWillEnterForeground) name:@"AppWillEnterForeground" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initalization

- (void)initProperties
{
    _currentState = CurrentStateNone;
    
    _isGPSNavi = NO;
    _shouleSendNotification = NO;
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
}

- (void)stopListenerForMessage
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.sessionDelegate removeMsgBlockWithKey:NSStringFromClass(self.class)];
}

- (void)initPoints
{
    _endPoint = [AMapNaviPoint locationWithLatitude:39.983456 longitude:116.315495];
}

- (void)initNaviManager
{
    if (self.naviManager == nil)
    {
        self.naviManager = [AMapNaviDriveManager sharedInstance];
    }
    
    [self.naviManager addDataRepresentative:self];
    [self.naviManager setDelegate:self];
}

- (void)initDriveView
{
    if (self.driveView == nil)
    {
        self.driveView = [[AMapNaviDriveView alloc] initWithFrame:self.view.bounds];
        self.driveView.delegate = self;
    }
    
    [self.driveView setDelegate:self];
}

- (void)initMapView
{
    if (_mapView == nil)
    {
        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    }
    
    [self.mapView setFrame:CGRectMake(0, 150, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-150)];
    [self.mapView setDelegate:self];
    [self.mapView addGestureRecognizer:_tapGesture];
    
    [self.view addSubview:self.mapView];
}

#pragma mark - Notification

- (void)receiveAppWillResignActive
{
    _shouleSendNotification = YES;
}

- (void)receiveAppWillEnterForeground
{
    _shouleSendNotification = NO;
}

#pragma mark - Handle Views

- (void)configSubViews
{
    _endPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 20)];
    
    _endPointLabel.textAlignment = NSTextAlignmentCenter;
    _endPointLabel.font = [UIFont systemFontOfSize:14];
    _endPointLabel.text = [NSString stringWithFormat:@"终 点：%f, %f", _endPoint.latitude, _endPoint.longitude];
    
    [self.view addSubview:_endPointLabel];
    
    UIButton *GPSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    GPSBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    GPSBtn.layer.borderWidth  = 0.5;
    GPSBtn.layer.cornerRadius = 5;
    
    [GPSBtn setFrame:CGRectMake(60, 60, 200, 30)];
    [GPSBtn setTitle:@"实时导航" forState:UIControlStateNormal];
    [GPSBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    GPSBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    
    [GPSBtn addTarget:self action:@selector(startGPSNavi:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:GPSBtn];
    
    UIButton *emulatorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    emulatorBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    emulatorBtn.layer.borderWidth  = 0.5;
    emulatorBtn.layer.cornerRadius = 5;
    
    [emulatorBtn setFrame:CGRectMake(60, 100, 200, 30)];
    [emulatorBtn setTitle:@"模拟导航" forState:UIControlStateNormal];
    [emulatorBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    emulatorBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    
    [emulatorBtn addTarget:self action:@selector(startEmulatorNavi:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:emulatorBtn];
}

#pragma mark - Actions

- (void)startGPSNavi:(id)sender
{
    _isGPSNavi = YES;
    
    [self calculateRoute];
}

- (void)startEmulatorNavi:(id)sender
{
    _isGPSNavi = NO;
    
    [self calculateRoute];
}

- (void)calculateRoute
{
    NSArray *endPoints = @[_endPoint];
    
    [self.naviManager calculateDriveRouteWithEndPoints:endPoints wayPoints:nil drivingStrategy:0];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)theSingleTap
{
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[theSingleTap locationInView:self.mapView]
                                              toCoordinateFromView:self.mapView];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [self.mapView addAnnotation:annotation];
    
    _endPoint = [AMapNaviPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    _endPointLabel.text = [NSString stringWithFormat:@"终 点：%f, %f", _endPoint.latitude, _endPoint.longitude];
}

#pragma mark - Override

- (void)setCurrentState:(CurrentState)currentState
{
    if (_currentState == currentState)
    {
        return;
    }
    
    _currentState = currentState;
    
    if (_currentState == CurrentStateNone)
    {
        [self sendDidStopNaviMessage];
    }
    else if (_currentState == CurrentStateStartNavi)
    {
        [self sendDidStartNaviMessage];
    }
}

#pragma mark - SendMessage

- (void)sendDidStartNaviMessage
{
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_ChangeNaviState,@"value":[NSNumber numberWithBool:YES]} replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"send did Start NaviMsg error:%@",error);
    }];
//    [self.wormhole passMessageObject:@{@"value":[NSNumber numberWithBool:YES]} identifier:MessageIdentifier_ChangeNaviState];
}

- (void)sendDidStopNaviMessage
{
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_ChangeNaviState,@"value":[NSNumber numberWithBool:NO]} replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"send did Stop NaviMsg error:%@",error);
    }];
//    [self.wormhole passMessageObject:@{@"value":[NSNumber numberWithBool:NO]} identifier:MessageIdentifier_ChangeNaviState];
}

- (void)sendNaviInfoMessage
{
    if (_savedNaviInfo == nil || self.currentState == CurrentStateNone)
    {
        return;
    }
    
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_UpdateNaviInfo,@"value":[_savedNaviInfo toDictionary]} replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"send navi info update error:%@",error);
    }];
//    [self.wormhole passMessageObject:@{@"value":[_savedNaviInfo copy]} identifier:MessageIdentifier_UpdateNaviInfo];
}

- (void)sendNaviGuideMessage
{
    if (self.currentState == CurrentStateNone)
    {
        return;
    }
    
    NSArray *guideList = [self.naviManager getNaviGuideList];
    NSMutableArray *guideListDict = [NSMutableArray array];
    for (AMapNaviGuide *guide in guideList) {
        if (guide) {
            NSDictionary *guideDict = [guide toDictionary];
            [guideListDict addObject:guideDict];
        }
    }
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_UpdateGuide,@"value":[guideListDict copy]} replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"send update guide error:%@",error);
    }];
}

- (void)sendTrafficImageMessage
{
    if (self.currentState == CurrentStateNone)
    {
        return;
    }
    
    NSArray *trafficArray = [self.naviManager getTrafficStatusesWithStartPosition:0 distance:(int)self.naviManager.naviRoute.routeLength];
    
    UIImage *image = [TrafficStatusCircle createCircleWithTrafficStatus:trafficArray imageSize:CGSizeMake(120, 120) lineWidth:14];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [[WCSession defaultSession] sendMessage:@{MessageIdentifierKey:MessageIdentifier_TrafficImage,@"value":imageData} replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"send traffic image error:%@",error);
    }];
//    [self.wormhole passMessageObject:@{@"value":image} identifier:MessageIdentifier_TrafficImage];
}

#pragma mark - ReceiveMessage
//使用消息block处理代理
- (void)handleReceivedMsg:(NSDictionary<NSString *,id> *)message {
    NSString *identifier = [message objectForKey:MessageIdentifierKey];
    if ([identifier isEqualToString:MessageIdentifier_WatchStopNavi]) {
        [self receiveStopNaviMessage:message];
    } else if ([identifier isEqualToString:MessageIdentifier_WatchCheck]) {
        [self receiveCheckMessage:message];
    }
}

- (void)receiveCheckMessage:(id)messageObject
{
    NSString *type = [messageObject valueForKey:@"value"];
    
    if ([type isEqualToString:@"isStartNavi"])
    {
        if (self.currentState == CurrentStateNone)
        {
            [self sendDidStopNaviMessage];
        }
        else
        {
            [self sendDidStartNaviMessage];
        }
    }
    else if ([type isEqualToString:@"getNaviInfo"])
    {
        [self sendNaviInfoMessage];
    }
    else if ([type isEqualToString:@"getGuideList"])
    {
        [self sendNaviGuideMessage];
    }
    else if ([type isEqualToString:@"getTrafficImage"])
    {
        [self sendTrafficImageMessage];
    }
}

- (void)receiveStopNaviMessage:(id)messageObject
{
    [self driveViewCloseButtonClicked:self.driveView];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    NSLog(@"error:{%@}",error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"OnCalculateRouteSuccess");
    
    [self sendNaviGuideMessage];
    
    if (self.driveView == nil)
    {
        [self initDriveView];
    }
    
    [self.naviManager addDataRepresentative:self.driveView];
    [self.view addSubview:self.driveView];
    
    if (_isGPSNavi)
    {
        [self.naviManager startGPSNavi];
    }
    else
    {
        [self.naviManager startEmulatorNavi];
    }
    
    self.currentState = CurrentStateStartNavi;
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"onCalculateRouteFailure");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
    
}

#pragma mark - AMapNaviDriveDataRepresentable

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviInfo:(AMapNaviInfo *)naviInfo
{
    _savedNaviInfo = naviInfo;
    
    [self sendNaviInfoMessage];
    
    if (_shouleSendNotification && _savedNaviInfo.segmentRemainDistance <= 15 && _savedNaviInfo.segmentRemainDistance > 0)
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        [notification setFireDate:[NSDate date]];
        [notification setAlertBody:[NSString stringWithFormat:@"%ld米后进入%@", (long)naviInfo.segmentRemainDistance, naviInfo.nextRoadName]];
        [notification setAlertTitle:@"导航提醒"];
        [notification setCategory:@"updateNaviInfo"];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateTrafficStatus:(NSArray<AMapNaviTrafficStatus *> *)trafficStatus
{
    NSLog(@"DidUpdateTrafficStatuses");
    
    [self sendTrafficImageMessage];
}

#pragma mark - AManNaviDriveView Delegate

- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView
{
    [self.naviManager stopNavi];
    
    [self.naviManager removeDataRepresentative:self.driveView];
    [self.driveView removeFromSuperview];
    self.driveView = nil;
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    
    self.currentState = CurrentStateNone;
}

- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView
{
    if (self.driveView.trackingMode == AMapNaviViewTrackingModeCarNorth)
    {
        self.driveView.trackingMode = AMapNaviViewTrackingModeMapNorth;
    }
    else
    {
        self.driveView.trackingMode = AMapNaviViewTrackingModeCarNorth;
    }
}

- (void)driveViewTrunIndicatorViewTapped:(AMapNaviDriveView *)driveView
{
    [self.naviManager readNaviInfoManual];
}

@end
