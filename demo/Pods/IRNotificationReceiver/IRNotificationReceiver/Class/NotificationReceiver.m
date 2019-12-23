//
//  NotificationReceiver.m
//  IRNotificationReceiver
//
//  Created by Phil on 2018/10/30.
//  Copyright © 2018年 Phil. All rights reserved.
//

#import "NotificationReceiver.h"

#define IR_NotificationReceiverIgnoreNotification @"IR_NotificationReceiverIgnoreNotification"
#define IR_IgnoreConditionerToObserverKey @"IR_IgnoreConditionerToObserver"

@interface NotificationConditioner()
@property (readwrite) NSInteger counter;
@end

@implementation NotificationConditioner
    
- (instancetype)initWithName:(NSString *)name {
    return [self initWithName:name minCount:1];
}
    
- (instancetype)initWithName:(NSString*)name minCount:(NSInteger)minCount {
    if (self = [super init]) {
        self.name = name;
        self.minCount = minCount;
        self.counter = minCount;
    }
    return self;
}

@end

@implementation SharedNotificationConditioner {
    NSMutableDictionary* dic;
}

static SharedNotificationConditioner *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        dic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NotificationConditioner*)sharedNotificationConditionerWithName:(NSString *)name {
    return [self sharedNotificationConditionerWithName:name minCount:1];
}

- (NotificationConditioner *)sharedNotificationConditionerWithName:(NSString *)name minCount:(NSInteger)minCount {
    NotificationConditioner* conditioner;
    if (!(conditioner = [dic objectForKey:name])) {
        conditioner = [[NotificationConditioner alloc] initWithName:name minCount:minCount];
        [dic setObject:conditioner forKey:name];
    } else {
        conditioner.minCount = minCount;
    }
    return conditioner;
}

- (BOOL)containConditionerWithName:(NSString*)name {
    NotificationConditioner* conditioner = [dic objectForKey:name];
    if(conditioner && [conditioner.name isEqualToString:name])
        return YES;
    return NO;
}

- (void)resetConditionerWithName:(NSString*)name {
    NotificationConditioner* conditioner = [dic objectForKey:name];
    if(conditioner && [conditioner.name isEqualToString:name])
        conditioner.counter = conditioner.minCount;
}

- (void)destroySharedNotificationConditionerWithName:(NSString *)name {
    [dic removeObjectForKey:name];
}

- (void)destroyAllSharedNotificationConditioners {
    for (NSString *key in dic.allKeys) {
        [self destroySharedNotificationConditionerWithName:key];
    }
}

- (void)destroySharedInstance {
    sharedInstance = nil;
    onceToken = 0;
}

@end

@implementation NotificationReceiver

- (instancetype)init {
    if (self = [super init]) {
        _conditioners = [NSMutableArray array];
        _enable = YES;
        _repeat = YES;
    }
    return self;
}

- (void)addObserver:(id)observer selector:(nonnull SEL)aSelector conditioner:(nonnull NotificationConditioner *)aConditioner object:(nullable id)anObject {
    [self addObserver:observer selector:aSelector conditioner:aConditioner ignoreable:NO object:anObject];
}

- (void)addObserver:(id)observer selector:(SEL)aSelector conditioner:(NotificationConditioner*)aConditioner ignoreable:(BOOL)ignoreable object:(nullable id)anObject {
    [_conditioners addObject:aConditioner];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aConditioner.name object:anObject];
    if (ignoreable) {
        [self addIgnoreConditionerWithName:aConditioner.name];
    }
}

- (void)removeObserver:(id)observer {
    [_conditioners removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)removeObserver:(id)observer conditioner:(nonnull NotificationConditioner *)aConditioner object:(nullable id)anObject {
    [_conditioners removeObject:aConditioner];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:aConditioner.name object:anObject];
}

- (void)addIgnoreConditionerWithName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIgnoreNotification:) name:IR_NotificationReceiverIgnoreNotification object:name];
}

- (void)checkConditionsWith:(NSString*)name verifity:(void (^)(BOOL isVerified)) verifity {
    if(!self.enable)
        return;
    BOOL isVerified = YES;
    for (NotificationConditioner* conditioner in _conditioners) {
        if(conditioner.counter > 0 && [conditioner.name isEqualToString:name]) {
            conditioner.counter--;
        }
        if (conditioner.counter > 0) {
            isVerified = NO;
        }
    }
    if (isVerified && _repeat) {
        for (NotificationConditioner* conditioner in _conditioners) {
            conditioner.counter = conditioner.minCount;
        }
    }
    if(verifity)
        verifity(isVerified);
}

- (void)ignoreConditioner:(NotificationConditioner*)aConditioner {
    [self ignoreConditionerWithName:aConditioner.name];
}

- (void)ignoreConditionerWithName:(NSString *)name {
    for (NotificationConditioner* conditioner in _conditioners) {
        if([conditioner.name isEqualToString:name]) {
            conditioner.counter = 0;
            break;
        }
    }
}

- (void)resetConditioners {
    for (NotificationConditioner* conditioner in _conditioners) {
        conditioner.counter = conditioner.minCount;
    }
}

- (BOOL)containConditionerWithName:(NSString*)name {
    for (NotificationConditioner* conditioner in _conditioners) {
        if([conditioner.name isEqualToString:name])
            return YES;
    }
    return NO;
}

- (void)receiveIgnoreNotification:(NSNotification*)notification {
    if(!self.enable)
        return;
    __nullable id observer = notification.userInfo[IR_IgnoreConditionerToObserverKey];
    if (observer == [NSNull null] || observer == self) {
        NSString* ignoreConditionerName = notification.object;
        [self ignoreConditionerWithName:ignoreConditionerName];
        if(self.delegate && [self.delegate respondsToSelector:@selector(receivedIgnoreConditionerWithName:)]) {
            [self.delegate receivedIgnoreConditionerWithName:ignoreConditionerName];
        }
    }
}

#pragma mark - Class method
+ (void)ignoreConditionerWithName:(NSString *)name {
    [NotificationReceiver ignoreConditionerWithName:name toObserver:nil];
}

+ (void)ignoreConditionerWithName:(NSString *)name userInfo:(nullable )userInfo {
    [NotificationReceiver ignoreConditionerWithName:name userInfo:userInfo toObserver:nil];
}

+ (void)ignoreConditionerWithName:(NSString *)name toObserver:(nullable id)observer {
    [NotificationReceiver ignoreConditionerWithName:name userInfo:nil toObserver:observer];;
}

+ (void)ignoreConditionerWithName:(NSString *)name userInfo:(nullable NSDictionary*)userInfo toObserver:(nullable id)observer {
    NSMutableDictionary* userInfoDic = [NSMutableDictionary dictionaryWithDictionary:@{IR_IgnoreConditionerToObserverKey : observer ? observer : [NSNull null]}];
    if (userInfo)
        [userInfoDic setDictionary:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IR_NotificationReceiverIgnoreNotification object:name userInfo:userInfoDic];
}

@end
