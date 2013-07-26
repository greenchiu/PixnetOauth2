//
//  PixnetOauth2.h
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PixnetOauth2 : NSObject
@property (nonatomic, readonly, copy) NSString* accessToken; /// access_token
@property (nonatomic, readonly, copy) NSString* refreshToken; /// refresh_token

/**
 * 建立Oauth grant accessToken實體
 *
 * @param consmuerId consumer_key
 * @param consumerSercet consumer_sercet
 */
- (id)initWithConsumerId:(NSString*)consmuerId
          comsumerSercet:(NSString*)consumerSercet;

/**
 * refresh the access_token.
 */
- (void)refreshAccessTokenWithCompletedHandler:(void(^)(BOOL successed, NSError* error))handler;
@end
