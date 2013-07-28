//
//  PixnetOauth2.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

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
    NSString* _authenticationScheme;
}

@end

@implementation PixnetOauth2

@synthesize accessToken  = _accessToken;
@synthesize refreshToken = _refreshToken;

- (void)dealloc {
//    NSLog(@"start dealloc:%@", self);
    _consumerId = nil;
    _consumerSercet = nil;
    _accessToken = nil;
    _refreshToken = nil;
    _refreshDate = nil;
    _authenticationScheme = nil;
}

- (id)copyWithZone:(NSZone *)zone {
    id copyObject = [[PixnetOauth2 alloc] initWithConsumerId:_consumerId
                                              comsumerSercet:_consumerSercet];
    if(copyObject) {
        [copyObject setValue:self.accessToken forKey:@"accessToken"];
        [copyObject setValue:self.refreshToken forKey:@"refreshToken"];
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
    static NSString* grantURLFormat = @"https://emma.pixnet.cc/oauth2/grant?grant_type=refresh_token&refresh_token=%@&client_id=%@&client_secret=%@";
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:grantURLFormat, self.refreshToken, _consumerId, _consumerSercet]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    url = nil;
    
    typeof(self) __weak w_self = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error){
                               BOOL successed = NO;
                               if(!error) {
                                   successed = YES;
                                   NSDictionary* dictOfOauth = [data objectFromJSONData];
//                                   NSLog(@"%@", dictOfOauth);
                                   
                                   [w_self setValue:dictOfOauth[@"access_token"] forKey:@"accessToken"];
                                   [w_self setValue:dictOfOauth[@"refresh_token"] forKey:@"refreshToken"];
                                   
//                                   NSLog(@"new refresh:%@", w_self.refreshToken);
//                                   NSLog(@"new access:%@", w_self.accessToken);
                               }
                               if(handler!=nil)
                                   handler(successed, error);
                           }];
    request = nil;
}

- (void)grantAccessTokenWithType:(PixnetOauth2GrantType *)grantType
                      withObject:(id)object
                         handler:(GrantCompletedHandler)handler {
    NSString* grantURL = [NSString stringWithFormat:@"https://emma.pixnet.cc/oauth2/grant?grant_type=%@&client_id=%@&client_secret=%@",grantType, _consumerId, _consumerSercet];
    
    NSError *error = nil;
    if([grantType isEqualToString:PixnetOauth2GrantTypeAuthorizationCode] && object) {
        
        if(![object isKindOfClass:[NSDictionary class]]) {
            // Error for Wrong Data Type, code = 2000
            error = [NSError errorWithDomain:@"com.pixnet.iossdk:ErrorParamsWrongDataTypeForGrantAuthoriztion"
                                        code:2000
                                    userInfo:nil];
            
        } else if (![object objectForKey:kAuthroizationCode] || ![object objectForKey:kRedirectUri]) {
            // Error for Lost Params Data, code = 2001
            error = [NSError errorWithDomain:@"com.pixnet.iossdk:ErrorLoseParamsForGrantAuthoriztion"
                                        code:2001
                                    userInfo:nil];
        }
        
        if(error) {
//            handler(NO, error);
//            return;
        }
        else {
            grantURL = [NSString stringWithFormat:@"%@&code=%@&redirect_uri=%@",
                        grantURL,
                        (id)object[kAuthroizationCode],
                        (id)object[kRedirectUri]];
        }
    } else {
        // Error for No Params for Request, code = 1000
        error = [NSError errorWithDomain:@"com.pixnet.iossdk:ErrorNoParamsForGrantAuthoriztion"
                                    code:1000
                                userInfo:nil];
//        handler(NO, error);
        return;
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
                               if(!error) {
                                   successed = YES;
                                   NSDictionary* dictOfOauth = [data objectFromJSONData];
                                   [w_self setValue:dictOfOauth[@"access_token"] forKey:@"accessToken"];
                                   [w_self setValue:dictOfOauth[@"refresh_token"] forKey:@"refreshToken"];
                               }
                               if(handler!=nil)
                                   handler(successed, error);
                           }];
    request = nil;
}

@end
