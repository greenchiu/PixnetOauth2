//
//  PixnetOauth2.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

/**
 * 筆記 2013/07/29 by Green
 * Oauth完畢後, 在取得的資訊上, 可以用在Http Header上加上 field [Authorization: token_type, value:access_token]
 * 來存取一些個人資訊(需驗證的內容), 之後應該加入新的Class, 專門處理Requst需要驗證的動作.
 * 不需驗證的內容, 該如何編入SDK, 也可以同時考慮
 */

#import "PixnetOauth2.h"
#import "JSONKit.h"

PixnetOauth2GrantType* const PixnetOauth2GrantTypeAuthorizationCode = @"authorization_code";
PixnetOauth2GrantType* const PixnetOauth2GrantTypeRefreshAccessToken = @"refresh_token";

@interface PixnetOauth2 () {
    NSString* _consumerId;
    NSString* _consumerSercet;
    NSString* _accessToken;
    NSString* _refreshToken;
    NSDate*   _refreshDate;
    NSString* _tokenType;
}

@end

@implementation PixnetOauth2

@synthesize accessToken  = _accessToken;
@synthesize refreshToken = _refreshToken;

- (void)dealloc {
    _consumerId = nil;
    _consumerSercet = nil;
    _accessToken = nil;
    _refreshToken = nil;
    _refreshDate = nil;
    _tokenType = nil;
}

- (id)copyWithZone:(NSZone *)zone {
    id copyObject = [[PixnetOauth2 alloc] initWithConsumerId:_consumerId
                                              comsumerSercet:_consumerSercet];
    if(copyObject) {
        [copyObject setValue:self.accessToken forKey:@"accessToken"];
        [copyObject setValue:self.refreshToken forKey:@"refreshToken"];
        NSString* tokenType = [self valueForKeyPath:@"tokenType"];
        [copyObject setValue:[tokenType copy] forKey:@"tokenType"];
    }
    return copyObject;
}

- (id)initWithConsumerId:(NSString *)consmuerId comsumerSercet:(NSString *)consumerSercet {
    self = [super init];
    if (self) {
        _consumerId = [[NSString alloc] initWithString:consmuerId];
        _consumerSercet = [[NSString alloc] initWithString:consumerSercet];
    }
    return self;
}

- (void)refreshAccessTokenWithCompletedHandler:(void (^)(BOOL, NSError *))handler {
    
    [self grantAccessTokenWithType:PixnetOauth2GrantTypeRefreshAccessToken
                        withObject:nil
                           handler:handler];
}

- (void)grantAccessTokenWithType:(PixnetOauth2GrantType *)grantType
                      withObject:(id)object
                         handler:(GrantCompletedHandler)handler {
    NSString* grantURL = [NSString stringWithFormat:@"https://emma.pixnet.cc/oauth2/grant?grant_type=%@&client_id=%@&client_secret=%@",grantType, _consumerId, _consumerSercet];
    
    NSError *error = nil;
    if([grantType isEqualToString:PixnetOauth2GrantTypeAuthorizationCode] && object) {
        
        if(![object isKindOfClass:[NSDictionary class]]) {
            // Error for Wrong Data Type, code = 2000
            error = [NSError errorWithDomain:@"com.greenchiu.pixnetiossdk:ErrorParamsWrongDataTypeForGrantAuthoriztion"
                                        code:2000
                                    userInfo:nil];
            
        } else if (![object objectForKey:kAuthroizationCode] || ![object objectForKey:kRedirectUri]) {
            // Error for Lost Params Data, code = 2001
            error = [NSError errorWithDomain:@"com.greenchiu.pixnetiossdk:ErrorLoseParamsForGrantAuthoriztion"
                                        code:2001
                                    userInfo:nil];
        }
        
        if(!error) {
            grantURL = [NSString stringWithFormat:@"%@&code=%@&redirect_uri=%@",
                        grantURL,
                        (id)object[kAuthroizationCode],
                        (id)object[kRedirectUri]];
        }
    } else if([grantType isEqualToString:PixnetOauth2GrantTypeAuthorizationCode] && object == nil) {
        // Error for No Params for Request, code = 1000
        error = [NSError errorWithDomain:@"com.greenchiu.pixnetiossdk:ErrorWithRequestParams"
                                    code:1000
                                userInfo:@{@"action":PixnetOauth2GrantTypeAuthorizationCode}];
    } else if ([grantType isEqualToString:PixnetOauth2GrantTypeRefreshAccessToken]) {
        grantURL = [NSString stringWithFormat:@"%@&refresh_token=%@",
                    grantURL,
                    _refreshToken];
    }
    
    if(error) {
        grantURL = nil;
        NSLog(@"[pixnet error]:%@", error);
        if(handler!=nil)
            handler(NO, error);
        return;
    }
    
    NSURL* url = [NSURL URLWithString:grantURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    grantURL = nil;
    url = nil;
    
    typeof(self) __weak w_self = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error){
                               BOOL successed = NO;
                               
                               NSDictionary* dictOfOauth = [data objectFromJSONData];
                               
                               /**
                                * 如果Request成功, 且沒有錯誤訊息, 才判定成功.
                                */
                               
                               if(!error && !dictOfOauth[@"error"]) {
                                   successed = YES;
                                   [w_self setValue:dictOfOauth[@"access_token"] forKey:@"accessToken"];
                                   [w_self setValue:dictOfOauth[@"refresh_token"] forKey:@"refreshToken"];
                                   [w_self setValue:dictOfOauth[@"token_type"] forKey:@"tokenType"];
                               } else {
                                   /**
                                    * 如果Request沒有Error, 有可能是因為Request Params有缺失, 所以直接將Response的訊息帶入
                                    */
                                   if(!error) {
                                       error = [NSError errorWithDomain:@"com.greenchiu.pixnetiossdk:ErrorWithRequestParams"
                                                                   code:1000
                                                               userInfo:dictOfOauth];
                                   }
                               }
                               if(handler!=nil)
                                   handler(successed, error);
                           }];
    request = nil;
}

@end
