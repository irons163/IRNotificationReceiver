//
//  NotificationReceiver.h
//  IRNotificationReceiver
//
//  Created by Phil on 2018/10/30.
//  Copyright © 2018年 Phil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NotificationReceiverDelegate <NSObject>

@optional
- (void)receivedIgnoreConditionerWithName:(NSString*)name;
@end

@interface NotificationConditioner : NSObject

@property NSString* name;
@property NSInteger minCount;
@property (readonly) NSInteger counter;

- (instancetype)initWithName:(NSString*)name; // default minCount = 1
- (instancetype)initWithName:(NSString*)name minCount:(NSInteger)minCount;
@end

@interface SharedNotificationConditioner : NSObject

-(id) init UNAVAILABLE_ATTRIBUTE;
+(id) new UNAVAILABLE_ATTRIBUTE;

+(instancetype)sharedInstance;

- (NotificationConditioner*)sharedNotificationConditionerWithName:(NSString*)name; // set default minCount = 1.
- (NotificationConditioner*)sharedNotificationConditionerWithName:(NSString*)name minCount:(NSInteger)minCount; // reset minCount if the specific conditioner exist.
- (BOOL)containConditionerWithName:(NSString*)name;
- (void)resetConditionerWithName:(NSString*)name;
- (void)destroySharedNotificationConditionerWithName:(NSString*)name;
- (void)destroyAllSharedNotificationConditioners;
- (void)destroySharedInstance;
@end

@interface NotificationReceiver : NSObject

@property BOOL enable; //default == YES
@property BOOL repeat; //default == YES
@property (readonly) NSMutableArray* conditioners;

@property (weak) id<NotificationReceiverDelegate> delegate;

- (void)addObserver:(id)observer selector:(SEL)aSelector conditioner:(NotificationConditioner*)aConditioner object:(nullable id)anObject;
- (void)addObserver:(id)observer selector:(SEL)aSelector conditioner:(NotificationConditioner*)aConditioner ignoreable:(BOOL)ignoreable object:(nullable id)anObject;
- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer conditioner:(NotificationConditioner*)aConditioner object:(nullable id)anObject;
- (void)addIgnoreConditionerWithName:(NSString*)name;

- (void)checkConditionsWith:(NSString*)name verifity:(void (^)(BOOL isVerified)) verifity;
//- (void)consumConditioner:(NotificationConditioner*)conditioner;
- (BOOL)containConditionerWithName:(NSString*)name;
- (void)resetConditioners;

- (void)ignoreConditioner:(NotificationConditioner*)aConditioner;
- (void)ignoreConditionerWithName:(NSString*)name;

+ (void)ignoreConditionerWithName:(NSString*)name;
+ (void)ignoreConditionerWithName:(NSString *)name userInfo:(nullable )userInfo;
+ (void)ignoreConditionerWithName:(NSString*)name toObserver:(nullable id)observer;
+ (void)ignoreConditionerWithName:(NSString *)name userInfo:(nullable NSDictionary*)userInfo toObserver:(nullable id)observer;
@end

NS_ASSUME_NONNULL_END
