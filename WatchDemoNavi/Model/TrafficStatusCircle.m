//
//  TrafficStatusCircle.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/16.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "TrafficStatusCircle.h"
#import <AMapNaviKit/AMapNaviCommonObj.h>

@implementation TrafficStatusCircle

+ (UIImage *)createCircleWithTrafficStatus:(NSArray *)trafficStatus imageSize:(CGSize)imageSize lineWidth:(double)lineWidth
{
    if (trafficStatus == nil || [trafficStatus count] == 0 || CGSizeEqualToSize(imageSize, CGSizeZero) || lineWidth <= 0)
    {
        return nil;
    }
    
    int totalLegth = 0;
    for (AMapNaviTrafficStatus *aTraffic in trafficStatus)
    {
        totalLegth += aTraffic.length;
    }
    
    double shadowBlur = 2.0;
    double totalRadians = 340 / 360.0 * 2 * M_PI;
    
    double minImageSize = MIN(imageSize.width, imageSize.height);
    double circleRadius = minImageSize/2.0 - lineWidth/2.0 - shadowBlur;
    double radiansScale = totalRadians / totalLegth;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(minImageSize, minImageSize), NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextRotateCTM(context, -M_PI_2);
    CGContextTranslateCTM(context, -minImageSize, 0);
    
    //Circle
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetShadow(context, CGSizeZero, shadowBlur);
    
    CGContextBeginPath(context);
    double startRadians = totalRadians;
    double endRadians = totalRadians;
    for (NSInteger i = [trafficStatus count]-1; i >= 0; i--)
    {
        AMapNaviTrafficStatus *aTraffic = [trafficStatus objectAtIndex:i];
        
        UIColor *aColor = [TrafficStatusCircle getColorWithStatus:aTraffic.status];
        endRadians = endRadians - aTraffic.length * radiansScale;
        
        CGContextSetStrokeColorWithColor(context, aColor.CGColor);
        CGContextAddArc(context, minImageSize/2.0, minImageSize/2.0, circleRadius, startRadians, endRadians, YES);
        CGContextStrokePath(context);
        
        startRadians = endRadians;
    }
    
    CGContextRestoreGState(context);
    
    //Arrow
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, lineWidth/10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    double arrowX = minImageSize/2.0 + circleRadius;
    double arrowY = minImageSize/2.0 - lineWidth/4.0;
    double arrowY_cusp = arrowY+lineWidth/2.0;
    CGContextMoveToPoint(context, arrowX, arrowY);
    CGContextAddLineToPoint(context, arrowX, arrowY_cusp);
    CGContextAddLineToPoint(context, arrowX-0.3*lineWidth, arrowY+0.2*lineWidth);
    CGContextMoveToPoint(context, arrowX, arrowY_cusp);
    CGContextAddLineToPoint(context, arrowX+0.3*lineWidth, arrowY+0.2*lineWidth);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    //Create Image
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

+ (UIColor *)getColorWithStatus:(NSInteger)status
{
    if (status == 1)
    {
        return [UIColor colorWithRed:65/255.0 green:223/255.0 blue:16/255.0 alpha:1.0];
    }
    else if (status == 2)
    {
        return [UIColor yellowColor];
    }
    else if (status == 3)
    {
        return [UIColor redColor];
    }
    else if (status == 4)
    {
        return [UIColor colorWithRed:160/255.0 green:8/255.0 blue:8/255.0 alpha:1.0];
    }
    else
    {
        return [UIColor colorWithRed:26/255.0 green:166/255.0 blue:239/255.0 alpha:1.0];
    }
}

@end
