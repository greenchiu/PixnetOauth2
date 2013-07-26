//
//  FBManager.h
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const FBManagerLoginSuccessedNotification;
extern NSString* const FBManagerRequestFailuredNotification;
extern NSString* const FBManagerRequestMeSuccessedNotification;


typedef void(^FacebookPostToFeedHandler)(id result, NSError* error);

@interface FBManager : NSObject
/**
 * 建立Session, 以檢查是否已登入FB
 */
+ (void)startSession;

/**
 * handleOpenURL, ... 因為改變登入模式, 可能沒有額外作用
 */
+ (BOOL)handleOpenURL:(NSURL*)url;

/**
 * 登入Facebook
 */
+ (void)login;

/**
 * 是否已登入
 */
+ (BOOL)isLogin;

/**
 * 取得fb的userName
 */
+ (NSString*)userName;

/**
 * 將要發表的內容貼到自己的塗鴉牆
 *
 * @param params 發佈的訊息
 * @param handler 失敗或完成的handler
 */
+ (void)postToFeedWithParamsters:(NSDictionary*)params handler:(FacebookPostToFeedHandler)handler;

@end
