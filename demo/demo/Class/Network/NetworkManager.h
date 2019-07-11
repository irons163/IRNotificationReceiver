//
//  NetworkManager.h
//  demo
//
//  Created by Phil on 2019/7/11.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^SucceccBlockType)(NSDictionary* ackResult);
typedef void (^FailureBlockType)(NSError* error,NSString* message);

@interface NetworkManager : NSObject

-(id) init UNAVAILABLE_ATTRIBUTE;
+(id) new UNAVAILABLE_ATTRIBUTE;

+(instancetype)sharedInstance;

@property BOOL alwaysFail;

#pragma mark - Demo API Request
- (void)getUserProfileCompletionBlockWithSuccess:(SucceccBlockType)successBlock Failure:(FailureBlockType)failureBlock;
- (void)getFriendsCompletionBlockWithSuccess:(SucceccBlockType)successBlock Failure:(FailureBlockType)failureBlock;
- (void)getMessagesCompletionBlockWithSuccess:(SucceccBlockType)successBlock Failure:(FailureBlockType)failureBlock;
@end
