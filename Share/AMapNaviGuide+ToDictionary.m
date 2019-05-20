//
//  AMapNaviGuide+ToDictionary.m
//  WatchDemoNavi
//
//  Created by lly on 2019/5/20.
//  Copyright © 2019 lly. All rights reserved.
//

#import "AMapNaviGuide+ToDictionary.h"

@implementation AMapNaviGuide (ToDictionary)

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (self.name) {
        [dict setObject:self.name forKey:@"name"];
    }
    if (self.length > -1) {
        [dict setObject:[NSNumber numberWithInteger:self.length] forKey:@"length"];
    }
    if (self.time) {
        [dict setObject:[NSNumber numberWithInteger:self.time] forKey:@"time"];
    }
    if (self.iconType) {
        [dict setObject:[NSNumber numberWithInteger:self.iconType] forKey:@"iconType"];
    }
//    if (self.coordinate) { //Payload contains unsupported type,WCSession 不能发送这个数据类型，需要支持序列化的数据类型
//        [dict setObject:self.coordinate forKey:@"coordinate"];
//    }
    return [dict copy];
}

@end
