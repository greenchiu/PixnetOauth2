//
//  PNRequest.m
//  pixnetfunapp
//
//  Created by Green on 13/7/29.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "PNRequest.h"
#import "PixnetOauth2.h"
#import "PixnetConfig.h"
#import "PNError.h"

#import "JSONKit.h"

NSString* const UserAccountAPI = @"/account";
NSString* const UserInfoAPI = @"/user";


@interface PNRequest () <NSURLConnectionDataDelegate> {
    NSURLConnection* _connection;
    NSMutableData* _receiveData;
    NSURLResponse* _response;
    
    PNRequestCompletedHandler _completedHandler;
}
@property (nonatomic, weak) PixnetOauth2* oauth;
@property (nonatomic, copy) NSURLResponse* response;
@property (nonatomic, copy) NSMutableData* receiveData;
@property (readwrite, copy) PNRequestCompletedHandler completedHandler;

/**
 * init the PNRequest's private properties
 */
- (void)initProperties;

- (void)requestOauthUserWithHandler:(PNRequestCompletedHandler)handler;
@end


@implementation PNRequest

@synthesize response = _response,
            receiveData = _receiveData,
            completedHandler = _completedHandler;

+ (void)requestOauthUserWithOauth:(PixnetOauth2 *)oauth completedHandler:(PNRequestCompletedHandler)handler {
    PNRequest* requst = [[PNRequest alloc] initWithOauth:oauth];
    [requst requestOauthUserWithHandler:handler];
    requst = nil;
}

- (void)dealloc {
    
    NSLog(@"pnrequest dealloc");
    self.oauth = nil;
    
    _connection = nil;
    _receiveData = nil;
    _response = nil;
    _completedHandler = nil;
}

- (id)init {
    if( (self = [super init]) ) {
        self.oauth = nil;
        [self initProperties];
    }
    return self;
}

- (id)initWithOauth:(PixnetOauth2 *)oauth {
    self = [super init];
    if(self) {
        self.oauth = oauth;
        [self initProperties];
    }
    return self;
}

- (void)requestOauthUserWithHandler:(PNRequestCompletedHandler)handler {
    NSError* error = nil;
    if(!self.oauth) {
        error = [NSError errorWithDomain:PixnetErrorOauthInvalid
                                    code:PixnetErrorInvalid
                                userInfo:@{@"error_message":@"the oauth is nil, requestOauthUserWithHandler need oauth."}];
        
        if(handler)
            handler(nil, error);
        
        return;
    }
    
    if(_connection) {
        [_connection cancel];
        _connection = nil;
    }
    
    self.completedHandler = handler;
    NSString* oauthUserInfoURL = [NSString stringWithFormat:@"https://%@%@?format=json&access_token=%@",
                                  PixnetHost,
                                  UserAccountAPI,
                                  self.oauth.accessToken];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:oauthUserInfoURL]];
    oauthUserInfoURL = nil;
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_connection start];
}


#pragma mark - private
- (void)initProperties {
    _receiveData = [[NSMutableData alloc] init];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    self.response = nil;
//    self.receiveData = nil;
    [self.receiveData setLength:0];
    
    if(self.completedHandler)
        self.completedHandler(nil, error);
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = nil;
//    self.receiveData = nil;
    [self.receiveData setLength:0];
    self.response = [response copy];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(self.response.expectedContentLength == self.receiveData.length) {
        if(self.completedHandler)
            self.completedHandler([self.receiveData objectFromJSONData], nil);
    } else {
        NSLog(@"error");
    }
    
    
    [self.receiveData setLength:0];
    self.response = nil;
    _connection = nil;
    self.completedHandler = nil;
}

@end
