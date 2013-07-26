//
//  FBManager.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "FBManager.h"

#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>

/**
 * 用來檢查現在session狀態的function
 */
void logFBSessionState(FBSession* session) {
    switch (session.state) {
        case FBSessionStateCreatedTokenLoaded:
            NSLog(@"FBSessionStateCreatedTokenLoaded");
            break;
        case FBSessionStateClosed:
            NSLog(@"FBSessionStateClosed");
            break;
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FBSessionStateClosedLoginFailed");
            break;
        case FBSessionStateCreated:
            NSLog(@"FBSessionStateCreated");
            break;
        case FBSessionStateOpen:
            NSLog(@"FBSessionStateOpen");
            break;
        case FBSessionStateOpenTokenExtended:
            NSLog(@"FBSessionStateOpenTokenExtended");
            break;
        case FBSessionStateCreatedOpening:
            NSLog(@"FBSessionStateCreatedOpening");
            break;
            
        default:
            break;
    }
}

NSString* const FBManagerLoginSuccessedNotification = @"FBManagerLoginSuccessedNotification";
NSString* const FBManagerRequestFailuredNotification = @"FBManagerRequestFailuredNotification";
NSString* const FBManagerRequestMeSuccessedNotification = @"FBManagerRequestMeSuccessedNotification";

@interface FBManager ()

@property (nonatomic, strong) FBSession* session; // session
@property (nonatomic, strong) NSDictionary<FBGraphUser> *user; // 自己的資訊

/**
 * 取得FBManager Singletion.
 */
+ (FBManager *)sharedInstance;

/**
 * 取得自己的資訊
 */
- (void)requestMe;

/**
 * 將資訊貼到個人牆上
 *
 * @param params  發佈資訊
 * @param handler completedHandler
 */
- (void)publishWithParamsters:(NSDictionary*)params handler:(FacebookPostToFeedHandler)handler;
@end

@implementation FBManager
#pragma mark - class mehtod
+ (FBManager *)sharedInstance {
    static FBManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FBManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+ (void)startSession {
    [FBManager sharedInstance];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [[FBManager sharedInstance].session handleOpenURL:url];
}

+ (void)login {
    
    FBSession* session = [FBManager sharedInstance].session;
    
    logFBSessionState(session);
    
    if(session.state == FBSessionStateCreatedTokenLoaded || session.state == FBSessionStateOpen) {
        [[FBManager sharedInstance] requestMe];
        return;
    }
    
    if(session.state == FBSessionStateClosed || session.state == FBSessionStateClosedLoginFailed) {
        /**
         * 再執行 openWithCompletionHandler(FB Connect)前, 必須要確保session狀態不再 FBSessionStateClosed
         * 否則會造成 crash (請看openWithCompletionHandler使用方式)
         */
        session = nil;
        FBSessionTokenCachingStrategy *tokenCachingStrategy = [[FBSessionTokenCachingStrategy alloc]
                                                               initWithUserDefaultTokenInformationKeyName:@"pixnetfunapp"];
        
        session = [[FBSession alloc] initWithAppID:nil
                                       permissions:@[@"publish_actions"]
                                   urlSchemeSuffix:nil
                                tokenCacheStrategy:tokenCachingStrategy];
        [FBManager sharedInstance].session = session;
    }
    
    [session openWithBehavior:FBSessionLoginBehaviorForcingWebView
            completionHandler:^(FBSession *session,
                                FBSessionState status,
                                NSError *error) {
                if(status == FBSessionStateOpen){
                    [[NSNotificationCenter defaultCenter] postNotificationName:FBManagerLoginSuccessedNotification
                                                                        object:nil];
                    [[FBManager sharedInstance] requestMe];
                } else if (status == FBSessionStateClosedLoginFailed) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FBManagerRequestFailuredNotification
                                                                        object:@"login failured"];
                }
            }];
    
//    [session openWithCompletionHandler:^(FBSession *session,
//                                         FBSessionState status,
//                                         NSError *error) {
//        if(status == FBSessionStateOpen){
//            NSLog(@"access_token:%@",session.accessTokenData.accessToken);
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:FBManagerLoginSuccessedNotification
//                                                                object:nil];
//            [[FBManager sharedInstance] requestMe];
//            
//        } else if (status == FBSessionStateClosedLoginFailed) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:FBManagerRequestFailuredNotification
//                                                                object:@"login failured"];
//        }
//    }];
    
}

+ (BOOL)isLogin {
    return ([FBManager sharedInstance].session.state == FBSessionStateCreatedTokenLoaded ||
            [FBManager sharedInstance].session.state == FBSessionStateOpen);
}

+ (NSString*)userName {
    return [FBManager sharedInstance].user[@"username"];
}

+ (void)postToFeedWithParamsters:(NSDictionary *)params handler:(FacebookPostToFeedHandler)handler {
    FBSession* session = [FBManager sharedInstance].session;
    if([session.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        [session requestNewPublishPermissions:@[@"publish_actions"]
                              defaultAudience:FBSessionDefaultAudienceFriends
                            completionHandler:^(FBSession *session, NSError *error) {
                                if (!error) {
                                    [[FBManager sharedInstance] publishWithParamsters:params
                                                                              handler:handler];
                                } else {
                                    handler(nil, error);
                                }
                            }];
    } else {
        [[FBManager sharedInstance] publishWithParamsters:params
                                                  handler:handler];
    }
}

#pragma mark - instance method
- (void)dealloc {
    self.session = nil;
    self.user = nil;
}

- (id)init {
    self = [super init];
    if(self) {
        FBSessionTokenCachingStrategy *tokenCachingStrategy = [[FBSessionTokenCachingStrategy alloc]
                                                               initWithUserDefaultTokenInformationKeyName:@"pixnetfunapp"];
        self.session = [[FBSession alloc] initWithAppID:nil
                                            permissions:@[@"publish_actions"]
                                        urlSchemeSuffix:nil
                                     tokenCacheStrategy:tokenCachingStrategy];
        
        self.user = (NSDictionary<FBGraphUser>*)[[NSUserDefaults standardUserDefaults] objectForKey:@"fbuser"];
        
        logFBSessionState(self.session);
        
    }
    return self;
}

- (void)requestMe {
    NSLog(@"hi, this is request me.");
//    @autoreleasepool {
//        FBRequest* me = [[FBRequest alloc] initWithSession:self.session
//                                                 graphPath:@"me"];
//        if(!self.session.isOpen) {
//            return;
//        }
//        
//        typeof(self) __weak w_self = self;
//        
//        [me startWithCompletionHandler:^(FBRequestConnection *connection,
//                                         NSDictionary<FBGraphUser> *user,
//                                         NSError *error) {
//            if (!error) {
//                NSLog(@"request me successed.");
//                w_self.user = user;
//                
//                [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"fbuser"];
//                NSLog(@"save to user default:%@",[NSNumber numberWithBool: [[NSUserDefaults standardUserDefaults] synchronize] ]);
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:FBManagerRequestMeSuccessedNotification
//                                                                    object:user.username];
//                
//            } else {
//                NSLog(@"request me failured.");
//                [[NSNotificationCenter defaultCenter] postNotificationName:FBManagerRequestFailuredNotification
//                                                                    object:@"request me failured"];
//                
//            }
//        }];
//    }

    FBRequest* me = [[FBRequest alloc] initWithSession:self.session
                                             graphPath:@"me"];
    if(!self.session.isOpen) {
        return;
    }
    
    typeof(self) __weak w_self = self;
    
    [me startWithCompletionHandler:^(FBRequestConnection *connection,
                                     NSDictionary<FBGraphUser> *user,
                                     NSError *error) {
        if (!error) {
            NSLog(@"request me successed.");
            w_self.user = user;
            
            [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"fbuser"];
            NSLog(@"save to user default:%@",[NSNumber numberWithBool: [[NSUserDefaults standardUserDefaults] synchronize] ]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FBManagerRequestMeSuccessedNotification
                                                                object:user.username];
            
        } else {
            NSLog(@"request me failured.");
            [[NSNotificationCenter defaultCenter] postNotificationName:FBManagerRequestFailuredNotification
                                                                object:@"request me failured"];
            
        }
    }];
}

- (void)publishWithParamsters:(NSDictionary*)params handler:(FacebookPostToFeedHandler)handler {
    FBRequestConnection* connection;
    
    FBRequest* request = [[FBRequest alloc] initWithSession:self.session
                                                  graphPath:@"me/feed"
                                                 parameters:params
                                                 HTTPMethod:@"POST"];
    
    
    connection = [[FBRequestConnection alloc] init];
    [connection addRequest:request
         completionHandler:^(FBRequestConnection* fbconnection,id result, NSError* error){
             handler(result, error);
         }];
    [connection start];
    
}
@end
