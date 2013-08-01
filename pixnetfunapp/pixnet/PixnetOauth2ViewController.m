//
//  PixnetOauth2ViewController.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "PixnetOauth2ViewController.h"

#import "PNError.h"

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
    /**
     * cancel 需要 invoke handler or add a cancel handler?
     */
//    NSError* error = [NSError errorWithDomain:PixnetErrorUserCancelOauth
//                                         code:PixnetOauthErrorCancel
//                                     userInfo:nil];
//    
//    self.completedHandler(nil, error);
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
                                if(success) {
                                    w_self.completedHandler([oauth copy], error);
                                } else {
                                    w_self.completedHandler(nil, error);
                                }
                                [w_self dismissViewControllerAnimated:YES completion:^{}];
                            }];
    
    return;
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
