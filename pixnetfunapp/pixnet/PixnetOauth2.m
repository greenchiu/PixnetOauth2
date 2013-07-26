//
//  PixnetOauth2.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "PixnetOauth2.h"
#import "JSONKit.h"

@interface PixnetOauth2 () {
    NSString* _consumerId;
    NSString* _consumerSercet;
    NSString* _accessToken;
    NSString* _refreshToken;
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
                                   NSLog(@"%@", dictOfOauth);
                                   
                                   [w_self setValue:dictOfOauth[@"access_token"] forKey:@"accessToken"];
                                   [w_self setValue:dictOfOauth[@"refresh_token"] forKey:@"refreshToken"];
                                   
                                   NSLog(@"new refresh:%@", w_self.refreshToken);
                                   NSLog(@"new access:%@", w_self.accessToken);
                               }
                               if(handler!=nil)
                                   handler(successed, error);
                           }];
    request = nil;
}

@end
