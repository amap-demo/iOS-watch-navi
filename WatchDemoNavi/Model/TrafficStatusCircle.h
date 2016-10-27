//
//  TrafficStatusCircle.h
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/16.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrafficStatusCircle : NSObject

+ (UIImage *)createCircleWithTrafficStatus:(NSArray *)trafficStatus
                                 imageSize:(CGSize)imageSize
                                 lineWidth:(double)lineWidth;

@end
