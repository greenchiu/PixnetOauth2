//
//  PixnetOauth2ViewController.h
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixnetSDK.h"


typedef void (^PixnetOauth2CompletedHandler)(PixnetOauth2* oauth, NSError *error);

/**
 * Pixnet Oauth2 的ViewController
 */
@interface PixnetOauth2ViewController : UIViewController <UIWebViewDelegate>

/**
 * 載入Oauth Page的WebView
 */
@property (nonatomic, weak) IBOutlet UIWebView* webView;

/**
 * 顯示現在是否正在載入中
 */
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* indicator;


/**
 * 關閉Oauth.
 */
- (IBAction)cancelOauth;

/**
 * 建立OauthController實體
 *
 * @param consumerId consumer_key
 * @param consumerSecret consumer_secret
 * @param redirectUrl redirect_uri
 * @param OauthHandler Oauth結束後的callback handler
 */
- (id)initOauthWithClientId:(NSString*)consumerId
               clientSecret:(NSString*)consumerSecret
                redirectUrl:(NSString*)redirectUrl
           completedHandler:(PixnetOauth2CompletedHandler)OauthHandler;



#if PIXNET_SDK_VERSION > PIXNET_SDK_001000
/**
 * 建立OauthController實體
 *
 * @param consumerId consumer_key
 * @param consumerSecret consumer_secret
 * @param redirectUrl redirect_uri
 * @param scopes not support ,set nil (permissions)
 * @param OauthHandler Oauth結束後的callback handler
 */
- (id)initOauthWithClientId:(NSString*)consumerId
               clientSecret:(NSString*)consumerSecret
                redirectUrl:(NSString*)redirectUrl
                     scopes:(NSArray*)scopes
           completedHandler:(PixnetOauth2CompletedHandler)OauthHandler;
#endif
@end
