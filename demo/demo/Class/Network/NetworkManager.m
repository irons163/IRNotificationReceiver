//
//  NetworkManager.m
//  demo
//
//  Created by Phil on 2019/7/11.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

static NetworkManager *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)destroySharedInstance{
    sharedInstance = nil;
    onceToken = 0;
}

#pragma mark - Demo API Request
- (void)getUserProfileCompletionBlockWithSuccess:(SucceccBlockType)successBlock Failure:(FailureBlockType)failureBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!self.alwaysFail)
                successBlock(@{});
            else
                failureBlock(nil, nil);
        });
    });
}

- (void)getFriendsCompletionBlockWithSuccess:(SucceccBlockType)successBlock Failure:(FailureBlockType)failureBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!self.alwaysFail)
                successBlock(@{});
            else
                failureBlock(nil, nil);
        });
    });
}

- (void)getMessagesCompletionBlockWithSuccess:(SucceccBlockType)successBlock Failure:(FailureBlockType)failureBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!self.alwaysFail)
                successBlock(@{});
            else
                failureBlock(nil, nil);
        });
    });
}

@end
