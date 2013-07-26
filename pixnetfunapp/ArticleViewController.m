//
//  ArticleViewController.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "ArticleViewController.h"
#import "JSONKit.h"
#import "FBPublishViewController.h"
#import "ArticleCommentViewController.h"

@interface ArticleViewController () <UIAlertViewDelegate>
@property (nonatomic, weak) NSDictionary* articleSimpleData; // article的簡易資訊
@property (nonatomic, weak) NSString* user; // pixnet's user account
@property (nonatomic, weak) PixnetOauth2* oauth;
@property (nonatomic, strong) NSString* password; // 如果需要輸入帳密, 由此參數儲存
@property (nonatomic, strong) NSString* description; // 取得分享的描述段落
@property (nonatomic, strong) NSString* commentPerm; //可留言權限. 0: 關閉留言, 1: 開放所有人留言, 2: 僅開放登入者留言, 3:開放好友留言.
@property (nonatomic, strong) NSString* commentHidden; //預設留言狀態. 0: 公開, 1: 強制隱藏. 預設為0(公開)


/**
 * 取得詳細的文章內容
 */
- (void)requestArticleContent;

/**
 *
 */
- (void)showComments;
@end

@implementation ArticleViewController

- (void)dealloc {
    self.articleSimpleData = nil;
    self.user = nil;
    self.oauth = nil;
    self.password = nil;
    self.description = nil;
    self.webView = nil;
    
    self.commentHidden = nil;
    self.commentPerm = nil;
}

- (id)initArticleViewControllerWithData:(NSDictionary *)data user:(NSString *)user oauth:(PixnetOauth2 *)oauth {
    self = [super initWithNibName:@"ArticleViewController" bundle:nil];
    if(self) {
        self.articleSimpleData = data;
        self.user = user;
        self.oauth = oauth;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithTitle:@"fbShare"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(shareFB)];
    UIBarButtonItem* item2 = [[UIBarButtonItem alloc] initWithTitle:@"comments"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showComments)];
    
    
    
    [self.navigationItem setRightBarButtonItems:@[item1, item2]];
    item2 = nil;
    item1 = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    
    /**
     * 嗯 簡易排除流程
     */
    if(self.commentHidden || self.commentPerm)
        return;
    
    if([self.articleSimpleData[@"status"] isEqualToString:@"3"]) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"plz enter the password"
                                                        message:[NSString stringWithFormat:@"tip:%@", self.articleSimpleData[@"password_hint"]]
                                                       delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert show];
        alert = nil;

        
        return;
    }
    
    [self requestArticleContent];
}

- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareFB {
    NSString* status = self.articleSimpleData[@"status"];
    NSArray* filter = @[@"1",@"4",@"5"];
    
    if( [filter indexOfObject:status] != NSNotFound ) {
        UIAlertView* alert;
        alert = [[UIAlertView alloc] initWithTitle:@"pixnet"
                                           message:@"這篇文章不開放分享(隱私, 草稿, 好友)"
                                          delegate:self
                                 cancelButtonTitle:@"確認"
                                 otherButtonTitles:nil];
        
        alert.tag = 1000;
        [alert show];
        alert = nil;
        
        status = nil;
        filter = nil;
        return;
    }
    
    status = nil;
    filter = nil;
    
    FBPublishViewController* plvController;
    plvController = [[FBPublishViewController alloc] initWithArticleData:self.articleSimpleData
                                                             description:self.description];
    
    [self presentViewController:plvController
                       animated:YES
                     completion:^{}];
}

#pragma mark - private
- (void)requestArticleContent {
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    /**
     * user 可傳可不傳,
     */
    NSString* formatString = nil;
    NSString* lastURLString;
    
    if(self.user) {
        formatString = @"emma.pixnet.cc/blog/articles/%@?user=%@&format=json";
        lastURLString = [NSString stringWithFormat:formatString, self.articleSimpleData[@"id"], self.user];
    } else {
        formatString = @"emma.pixnet.cc/blog/articles/%@?format=json";
        lastURLString = [NSString stringWithFormat:formatString, self.articleSimpleData[@"id"]];
    }
    formatString = nil;
    
    NSString* status = self.articleSimpleData[@"status"];
    
    if([status isEqualToString:@"3"]) {
        lastURLString = [NSString stringWithFormat:@"%@&article_password=%@", lastURLString, self.password];
    }
    
    /**
     * 不確定有哪些需要使用到 https 目前只有設定 隱藏跟草稿, 好友可看的部份
     */
    
    NSArray* filter = kArticleFilter;
    
    if( [filter indexOfObject:status] != NSNotFound ) {
        lastURLString = [NSString stringWithFormat:@"https://%@&access_token=%@",lastURLString, self.oauth.accessToken];
    } else {
        lastURLString = [NSString stringWithFormat:@"http://%@",lastURLString];
    }
    filter = nil;
    status = nil;
    
    NSURL *url = [NSURL URLWithString:lastURLString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    lastURLString = nil;
    url = nil;
    
    typeof(self) __weak w_self = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
                               app.networkActivityIndicatorVisible = NO;
                               if(!error) {
                                   NSDictionary* result = [data objectFromJSONData];
                                   if([result[@"error"] integerValue] != 0) {
                                       
                                       [[[UIAlertView alloc] initWithTitle:@"發生錯誤"
                                                                  message:result[@"message"]
                                                                 delegate:w_self
                                                        cancelButtonTitle:@"確認"
                                                         otherButtonTitles:nil] show];
                                       
                                       return;
                                   }
                                   
                                   NSDictionary* content = result[@"article"];
                                   
                                   NSString* bodyString = content[@"body"];
                                   
                                   NSInteger length = [bodyString length];
                                   length = MIN(length, 20);
                                   
                                   w_self.description = [bodyString substringWithRange:NSMakeRange(0, length)];
                                   [w_self.webView loadHTMLString:bodyString baseURL:nil];
                                   
                                   //
                                   w_self.commentPerm = content[@"comment_perm"];
                                   w_self.commentHidden = content[@"comment_hidden"];
                                   
                               } else {
                                   
                                   [[NSNotificationCenter defaultCenter] postNotificationName:RequestFailureNotification
                                                                                       object:error.description];
                               }
                           }];
    request = nil;
}

- (void)showComments {
    
    
    if([self.commentHidden integerValue]==1) {
        UIAlertView* alert;
        alert = [[UIAlertView alloc] initWithTitle:@"pixnet"
                                           message:@"這篇文章不開放留言"
                                          delegate:self
                                 cancelButtonTitle:@"確認"
                                 otherButtonTitles:nil];
        
        alert.tag = 1000;
        [alert show];
        alert = nil;
        return;
    }
    
    ArticleCommentViewController* acvc = [[ArticleCommentViewController alloc] initWithUser:kDefaultUser
                                                                                    article:self.articleSimpleData
                                                                                      oauth:self.oauth];
    acvc.password = self.password;
    [self.navigationController pushViewController:acvc
                                         animated:YES];
    acvc = nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        UITextField* input = [alertView textFieldAtIndex:0];
        self.password = input.text;
        [self requestArticleContent];
        
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissAlertView" object:nil];
    if(buttonIndex == 0 && alertView.tag != 1000)
        [self cancel];
}



@end
