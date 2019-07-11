//
//  ViewController.m
//  demo
//
//  Created by Phil on 2019/7/10.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "ViewController.h"
#import "Network/NetworkManager.h"
#import <IRNotificationReceiver/IRNotificationReceiver.h>

#define GetUserProfileSuccessNotification @"GetUserProfileSuccessNotification"
#define GetFriendsSuccessNotification @"GetFriendsSuccessNotification"
#define GetMessagesSuccessNotification @"GetMessagesSuccessNotification"

@interface ViewController ()<NotificationReceiverDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@end

@implementation ViewController {
    NotificationReceiver* notificationReceiver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupNotificationReceiver {
    notificationReceiver = [[NotificationReceiver alloc] init];
    notificationReceiver.repeat = NO;
    notificationReceiver.delegate = self;
    
    [notificationReceiver addObserver:self selector:@selector(completionNotifications:) conditioner:[[NotificationConditioner alloc] initWithName:GetUserProfileSuccessNotification minCount:1] ignoreable:YES object:nil];
    [notificationReceiver addObserver:self selector:@selector(completionNotifications:) conditioner:[[NotificationConditioner alloc] initWithName:GetFriendsSuccessNotification minCount:1] ignoreable:YES object:nil];
    [notificationReceiver addObserver:self selector:@selector(completionNotifications:) conditioner:[[NotificationConditioner alloc] initWithName:GetMessagesSuccessNotification minCount:1] ignoreable:YES object:nil];
}

- (void)setupSharedNotificationReceiver {
    notificationReceiver = [[NotificationReceiver alloc] init];
    notificationReceiver.repeat = NO;
    notificationReceiver.delegate = self;
    
    [notificationReceiver addObserver:self selector:@selector(completionNotifications:) conditioner:[[SharedNotificationConditioner sharedInstance] sharedNotificationConditionerWithName:GetUserProfileSuccessNotification minCount:1] ignoreable:YES object:nil];
    [notificationReceiver addObserver:self selector:@selector(completionNotifications:) conditioner:[[SharedNotificationConditioner sharedInstance] sharedNotificationConditionerWithName:GetFriendsSuccessNotification minCount:1] ignoreable:YES object:nil];
    [notificationReceiver addObserver:self selector:@selector(completionNotifications:) conditioner:[[SharedNotificationConditioner sharedInstance] sharedNotificationConditionerWithName:GetMessagesSuccessNotification minCount:1] ignoreable:YES object:nil];
}

- (void)resetReceiver {
    [notificationReceiver resetConditioners];
}

- (IBAction)demoForSequentialAPIs:(id)sender {
    if(!notificationReceiver)
        [self setupNotificationReceiver];
    else
        [self resetReceiver];
    [self willUpdate];
    
    [NetworkManager sharedInstance].alwaysFail = NO;
    [[NetworkManager sharedInstance] getUserProfileCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GetUserProfileSuccessNotification object:nil userInfo:nil];
        
        [[NetworkManager sharedInstance] getFriendsCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GetFriendsSuccessNotification object:nil userInfo:nil];
            
            [[NetworkManager sharedInstance] getMessagesCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GetMessagesSuccessNotification object:nil userInfo:nil];
            } Failure:^(NSError *error, NSString *message) {
                
            }];
        } Failure:^(NSError *error, NSString *message) {
            
        }];
    } Failure:^(NSError *error, NSString *message) {
        
    }];
}

- (IBAction)demoForConcurentAPIs:(id)sender {
    if(!notificationReceiver)
        [self setupNotificationReceiver];
    else
        [self resetReceiver];
    [self willUpdate];
    
    [NetworkManager sharedInstance].alwaysFail = NO;
    [[NetworkManager sharedInstance] getUserProfileCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GetUserProfileSuccessNotification object:nil userInfo:nil];
    } Failure:^(NSError *error, NSString *message) {
        
    }];
    [[NetworkManager sharedInstance] getFriendsCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GetFriendsSuccessNotification object:nil userInfo:nil];
    } Failure:^(NSError *error, NSString *message) {
        
    }];
    [[NetworkManager sharedInstance] getMessagesCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GetMessagesSuccessNotification object:nil userInfo:nil];
    } Failure:^(NSError *error, NSString *message) {
        
    }];
}

- (IBAction)demoForFailAPIs:(id)sender {
    if(!notificationReceiver)
        [self setupNotificationReceiver];
    else
        [self resetReceiver];
    [self willUpdate];
    
    [NetworkManager sharedInstance].alwaysFail = YES;
    [[NetworkManager sharedInstance] getUserProfileCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
       
    } Failure:^(NSError *error, NSString *message) {
        [NotificationReceiver ignoreConditionerWithName:GetUserProfileSuccessNotification];
    }];
    [[NetworkManager sharedInstance] getFriendsCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
        
    } Failure:^(NSError *error, NSString *message) {
        [NotificationReceiver ignoreConditionerWithName:GetFriendsSuccessNotification];
    }];
    [[NetworkManager sharedInstance] getMessagesCompletionBlockWithSuccess:^(NSDictionary *ackResult) {
        
    } Failure:^(NSError *error, NSString *message) {
        [NotificationReceiver ignoreConditionerWithName:GetMessagesSuccessNotification];
    }];
}

#pragma mark - NSNotification Function
- (void)completionNotifications:(NSNotification *)notification {
    [self checkUpdateWithNotificationName:notification.name];
}

- (void)willUpdate {
    self.statusLabel.text = @"";
    [self.loadingView startAnimating];
    self.view.userInteractionEnabled = NO;
}

- (void)didUpdate {
    [self.loadingView stopAnimating];
    self.view.userInteractionEnabled = YES;
}

- (void)checkUpdateWithNotificationName:(NSString*)name {
    [notificationReceiver checkConditionsWith:name verifity:^(BOOL isVerified) {
        if(name) {
            self.statusLabel.text = [self.statusLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@ %@\n", [name stringByReplacingOccurrencesOfString:@"SuccessNotification" withString:@""], @"Success."]];
        }
        
        if(isVerified) {
            [self didUpdate];
        }
    }];
}

#pragma mark - NotificationReceiverDelegate
- (void)receivedIgnoreConditionerWithName:(NSString *)name {
    self.statusLabel.text = [self.statusLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@ %@\n", [name stringByReplacingOccurrencesOfString:@"SuccessNotification" withString:@""], @"Fail."]];
    [self checkUpdateWithNotificationName:nil];
}

@end
