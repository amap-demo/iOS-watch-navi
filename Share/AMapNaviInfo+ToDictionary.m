//
//  AMapNaviInfo+ToDictionary.m
//  WatchDemoNavi
//
//  Created by lly on 2019/5/19.
//  Copyright © 2019 lly. All rights reserved.
//

#import "AMapNaviInfo+ToDictionary.h"

@implementation AMapNaviInfo (ToDictionary)

- (NSDictionary *)toDictionary {
    //查看需要传送那些元素
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (self.currentRoadName) {
        [dict setObject:self.currentRoadName forKey:@"currentRoadName"];
    }
    if (self.nextRoadName) {
        [dict setObject:self.nextRoadName forKey:@"nextRoadName"];
    }

    [dict setObject:[NSNumber numberWithInteger:self.iconType] forKey:@"iconType"];
    
    if (self.segmentRemainDistance >= 0) {
        [dict setObject:[NSNumber numberWithInteger:self.segmentRemainDistance] forKey:@"segmentRemainDistance"];
    }
    if (self.routeRemainDistance >= 0) {
        [dict setObject:[NSNumber numberWithInteger:self.routeRemainDistance] forKey:@"routeRemainDistance"];
    }
    if (self.routeRemainTime >= 0) {
        [dict setObject:[NSNumber numberWithInteger:self.routeRemainTime] forKey:@"routeRemainTime"];
    }
    return [dict copy];
}

@end
