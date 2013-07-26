//
//  ArticleViewController.h
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixnetOauth2.h"

/**
 * 顯示文章內容, 近來時會先進行Request, 如果需要密碼, 需要輸入密碼後才Request
 */
@interface ArticleViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView* webView; // 呈現資料的 webView

/**
 * 建立ArticleViewController實體
 *
 * @param data article的簡易資訊
 * @param user pixnet's account
 */
- (id)initArticleViewControllerWithData:(NSDictionary*)data
                                   user:(NSString*)user
                                  oauth:(PixnetOauth2*)oauth;

/**
 * 前往分享畫面
 */
- (IBAction)shareFB;

/**
 * 回到上一頁 
 */
- (IBAction)cancel;
@end
