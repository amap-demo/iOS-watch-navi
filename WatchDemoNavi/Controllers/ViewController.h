//
//  ViewController.h
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/11.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

typedef NS_ENUM(NSInteger, CurrentState)
{
    CurrentStateNone,
    CurrentStateStartNavi,
};

@interface ViewController : UIViewController<MAMapViewDelegate,AMapNaviDriveManagerDelegate>

@property (nonatomic, assign) CurrentState currentState;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapNaviDriveManager *naviManager;

@end
