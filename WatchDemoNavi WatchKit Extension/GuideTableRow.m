//
//  GuideTableRow.m
//  WatchDemoNavi
//
//  Created by 刘博 on 15/6/15.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "GuideTableRow.h"
#import <AMapNaviKit/AMapNaviCommonObj.h>

@interface GuideTableRow ()

@property (nonatomic, weak) IBOutlet WKInterfaceImage *turnIcon;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *infoLabel;

@end

@implementation GuideTableRow

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

#pragma mark - Override

- (void)setGuideItem:(AMapNaviGuide *)guideItem
{
    [self.turnIcon setImageNamed:[self buildImageNameWithIconType:guideItem.iconType]];
    
    NSMutableString *infoString = [[NSMutableString alloc] init];
    if ([guideItem.name isEqualToString:@""])
    {
        [infoString appendString:@"无名道路"];
    }
    else
    {
        [infoString appendString:guideItem.name];
    }
    
    [infoString appendFormat:@" - %@", [self normalizedRemainDistance:guideItem.length]];
    
    [self.infoLabel setText:infoString];
}

#pragma mark - Utility

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

@end
