//
//  ShareName.h
//  watch-Demo
//
//  Created by lly on 2019/5/17.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^receiveMsgBlock)(NSDictionary<NSString *,id> *message);

@interface SessionDelegate : NSObject<WCSessionDelegate>

@property (nonatomic,copy) NSString *name;
//@property (nonatomic,copy) receiveMsgBlock receiveMsgBlock;

- (void)setReceiveMsgBlock:(receiveMsgBlock)block withKey:(NSString *)key;

- (void)removeMsgBlockWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
