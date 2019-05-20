//
//  ShareName.m
//  watch-Demo
//
//  Created by lly on 2019/5/17.
//  Copyright © 2019 lly. All rights reserved.
//

#import "SessionDelegate.h"

@interface SessionDelegate ()

@property (nonatomic,strong) NSMutableDictionary<NSString*,receiveMsgBlock> *receiveMsgBlockDict;

@end

@implementation SessionDelegate

- (void)setReceiveMsgBlock:(receiveMsgBlock)block withKey:(NSString *)key {
    if (_receiveMsgBlockDict == nil) {
        self.receiveMsgBlockDict = [NSMutableDictionary dictionary];
    }
    if (key && block) {
        [_receiveMsgBlockDict setObject:block forKey:key];
    }
}

- (void)removeMsgBlockWithKey:(NSString *)key {
    [_receiveMsgBlockDict removeObjectForKey:key];
}

#pragma mark - WCSessionDelegate
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    
}

- (void)sessionDidBecomeInactive:(WCSession *)session {
    NSLog(@"%s",__func__);
}

- (void)sessionDidDeactivate:(WCSession *)session {
    NSLog(@"%s",__func__);
}

- (void)sessionReachabilityDidChange:(WCSession *)session {
    
}

/** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
    NSLog(@"%@ got msg:%@",self.name,message);
    if (_receiveMsgBlockDict.count > 0) {
        for (receiveMsgBlock block in [_receiveMsgBlockDict allValues]) {
            block(message);
        }
    }
}

/** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler {
    NSLog(@"%@ got msg:%@",self.name,message);
    if (_receiveMsgBlockDict.count > 0) {
        for (receiveMsgBlock block in [_receiveMsgBlockDict allValues]) {
            block(message);
        }
    }
    if (replyHandler) {
        replyHandler(@{@"key":@"replay"});
    }
}

@end
