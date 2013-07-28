//
//  PixnetOauth2ViewController.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "PixnetOauth2ViewController.h"
#import "JSONKit.h"

@interface PixnetOauth2ViewController ()
@property (nonatomic, copy) PixnetOauth2CompletedHandler completedHandler;

@property (nonatomic, strong) NSString* consumerId;
@property (nonatomic, strong) NSString* consumerSecret;
@property (nonatomic, strong) NSString* redirectUrl;
- (void)startRquestOauth2;
- (void)grantTokensWithCode:(NSString*)code;
@end

@implementation PixnetOauth2ViewController

- (void)dealloc {
    self.consumerId = nil;
    self.consumerSecret = nil;
    self.redirectUrl = nil;
    self.webView = nil;
    self.indicator = nil;
}


- (id)initOauthWithClientId:(NSString *)consumerId
               clientSecret:(NSString *)consumerSecret
                redirectUrl:(NSString *)redirectUrl
           completedHandler:(PixnetOauth2CompletedHandler)Oauth2Handler {
    self = [super initWithNibName:@"PixnetOauth2ViewController" bundle:nil];
    if(self) {
        self.consumerId = consumerId;
        self.consumerSecret = consumerSecret;
        self.redirectUrl = redirectUrl;
        self.completedHandler = Oauth2Handler;
    }
    return self;
}

- (void)cancelOauth {
    self.completedHandler(nil, YES, nil);
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self startRquestOauth2];
}

#pragma mark

- (void)startRquestOauth2 {
    static NSString* oauthURLFormat = @"https://emma.pixnet.cc/oauth2/authorize?redirect_uri=%@&client_id=%@&response_type=code";
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:oauthURLFormat, self.redirectUrl, self.consumerId]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)grantTokensWithCode:(NSString *)code {
    
    [self.indicator startAnimating];
    
    __block PixnetOauth2* oauth = [[PixnetOauth2 alloc] initWithConsumerId:self.consumerId
                                                            comsumerSercet:self.consumerSecret];
    
    typeof(self) __weak w_self = self;
    [oauth grantAccessTokenWithType:PixnetOauth2GrantTypeAuthorizationCode
                         withObject:@{kAuthroizationCode:code, kRedirectUri:self.redirectUrl}
                            handler:^(BOOL success, NSError* error){
                                NSLog(@"%@", oauth);
                                if(success) {
                                    w_self.completedHandler([oauth copy], YES, error);
                                } else {
                                    w_self.completedHandler(nil, NO, error);
                                }
                                [w_self dismissViewControllerAnimated:YES completion:^{}];
                            }];
    
    return;
    
    static NSString* grantURLFormat = @"https://emma.pixnet.cc/oauth2/grant?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@";
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:grantURLFormat,code,self.redirectUrl, self.consumerId, self.consumerSecret]];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    
//    typeof(self) __weak w_self = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error){
                               [w_self.indicator stopAnimating];
                               
                               if(!error) {
                                   NSDictionary* dictOfOauth = [data objectFromJSONData];
                                   PixnetOauth2* oauth = [[PixnetOauth2 alloc] initWithConsumerId:w_self.consumerId
                                                                                   comsumerSercet:w_self.consumerSecret];
                               
                                   [oauth setValue:dictOfOauth[@"access_token"] forKey:@"accessToken"];
                                   [oauth setValue:dictOfOauth[@"refresh_token"] forKey:@"refreshToken"];
                                   w_self.completedHandler(oauth, NO, nil);
                               } else {
                                   w_self.completedHandler(nil, NO, error);
                               }
                               
                               [w_self dismissViewControllerAnimated:YES completion:^{}];
                           }];
    
}

#pragma mark - UIWebView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if([[request.URL host] isEqualToString:@"localhost"]) {
        NSString* responseURL = [request.URL description];
        NSString* code = [[responseURL componentsSeparatedByString:@"?"] lastObject];
        NSString* codeValue = [[code componentsSeparatedByString:@"="] lastObject];
        [self grantTokensWithCode:codeValue];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.indicator stopAnimating];
}

@end
