//
//  PixnetOauth2.h
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PixnetVersions.h"

#define kRedirectUri @"redirect_uri"
#define kAuthroizationCode @"authroization_code"

typedef NSString PixnetOauth2GrantType;
extern PixnetOauth2GrantType* const PixnetOauth2GrantTypeAuthorizationCode;
extern PixnetOauth2GrantType* const PixnetOauth2GrantTypeRefreshAccessToken;

typedef void (^GrantCompletedHandler)(BOOL successed, NSError* error);

@interface PixnetOauth2 : NSObject <NSCopying>
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

/**
 * grand access_token & refresh_token
 *
 * @param grantType input PixnetOauth2GrantType, if grandType = PixnetOauth2GrantTypeAuthorizationCode, 
 *                  the object need put the authorization_code and redirect_uri, else just input nil.
 *
 * @param object if type != PixnetOauth2GrantTypeAuthorizationCode, keep it nil.
 * @param handler after the grant access_token, will invoke the handler.
 */
- (void)grantAccessTokenWithType:(PixnetOauth2GrantType*)grantType withObject:(id)object handler:(GrantCompletedHandler)handler;

@end
