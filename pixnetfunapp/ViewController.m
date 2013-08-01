//
//  ViewController.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#define consumer_key @"7fa57f8729b71b0193c26339b6ce3ffc"
#define consumer_sercet @"ae356f144edebb89f18495f1864219e3"
#define redirect_uri @"http://localhost"

#import "ViewController.h"
#import "PixnetOauth2ViewController.h"
#import "JSONKit.h"
#import "ArticleViewController.h"
#import "ArticleListViewController.h"
#import "FBManager.h"

#import "MBProgressHUD.h"

#import "PNRequest.h"

@interface ViewController ()
@property (nonatomic, strong) PixnetOauth2 *pixnetOauth; // 取得的 pixnet Oauth
@property (nonatomic, strong) NSString* pixnetAccount; 
@property (nonatomic, strong) NSMutableArray* articles; // 文章列表
@property (nonatomic, strong) NSMutableArray* categoriesOfArticle;

/**
 * 處理 FBManager 發出的 Notification
 * 
 * @param notify notification.
 */
- (void)handleFBManagerNotification:(NSNotification*)notify;

/**
 * 取得在pixnet上的個人資料
 */
- (void)requestUserData;

/**
 * 取得user的文章分類, default = handkid0115
 */
- (void)requestCategoriesWithUser:(NSString*)user;

@end



@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.pixnetAccount = nil;
    self.pixnetOauth = nil;
    self.articles = nil;
    self.categoriesOfArticle = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.fblogin setImage:[UIImage imageNamed:@"FacebookSDKResources.bundle/FBLoginView/images/f_logo.png"]
                  forState:UIControlStateNormal];
    
	//
    NSString* notifications[3] = {FBManagerRequestMeSuccessedNotification, FBManagerRequestFailuredNotification, FBManagerLoginSuccessedNotification};
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    for (int index = 0; index < 3; index++) {
        [center addObserver:self
                   selector:@selector(handleFBManagerNotification:)
                       name:notifications[index]
                     object:nil];
    }
    center = nil;
    self.articles = [[NSMutableArray alloc] initWithCapacity:0];
    
    if([FBManager isLogin]) {
        [self.fblogin setEnabled:NO];
        self.fbaccountLabel.text = [FBManager userName];
    }
    
    
    self.categoriesOfArticle = [[NSMutableArray alloc] initWithCapacity:0];
    [self.categoriesOfArticle addObjectsFromArray:@[
     @{ @"title":@"最新文章", @"path":@"latest"},
     @{ @"title":@"熱門文章", @"path":@"hot"}]];
    
    [self requestCategoriesWithUser:kDefaultUser];
}

- (void)loginFb {
    [self.fblogin setEnabled:NO];
    [FBManager login];
}

- (void)requestOauth {
    /**
     * 測試 RefreshOauth
     */
    if (self.pixnetOauth) {
        [self.pixnetOauth refreshAccessTokenWithCompletedHandler:^(BOOL successed, NSError* error){
            if(successed) {
                NSLog(@"更新accessToken成功");
            } else {
                NSLog(@"更新失敗, error:%@", error);
            }
        }];
        return;
    }
    
    
    [self.loginButton setEnabled:NO];
    typeof(self) __weak w_self = self;
    PixnetOauth2CompletedHandler handler = ^(PixnetOauth2* oauth, NSError* error) {
        if(oauth) {
            [w_self.loginButton setTitle:@"oauth refresh" forState:UIControlStateNormal];
            [w_self.loginButton setEnabled:YES];
            NSLog(@"%@", oauth);
            w_self.pixnetOauth = oauth;
            [w_self requestUserData];
        }
        if(error) {
            [w_self.loginButton setEnabled:YES];
        }
    };
    
    PixnetOauth2ViewController* pnoController;
    pnoController = [[PixnetOauth2ViewController alloc] initOauthWithClientId:consumer_key
                                                                 clientSecret:consumer_sercet
                                                                  redirectUrl:redirect_uri
                                                             completedHandler:handler];
    [self presentViewController:pnoController animated:YES completion:^{}];
    pnoController = nil;
}

#pragma mark
- (void)handleFBManagerNotification:(NSNotification*)notify {
    NSString* notifyName = notify.name;
    if([notifyName isEqualToString:FBManagerLoginSuccessedNotification]) {
        //        self.fblogin
    } else if ([notifyName isEqualToString:FBManagerRequestFailuredNotification]) {
        NSLog(@"%@", notify.object);
    } else {
        self.fbaccountLabel.text = (NSString*)notify.object;
    }
}

- (void)requestUserData {
    
    typeof(self) __weak w_self = self;
    [PNRequest requestOauthUserWithOauth:self.pixnetOauth
                        completedHandler:^(NSDictionary* data, NSError *error) {
                            if(!error) {
                                NSLog(@"%@", data);
//                                NSDictionary* dictOfResponseData = [data objectFromJSONData];
                                w_self.pixnetAccount = data[@"account"][@"identity"];
                                w_self.accountLabel.text = w_self.pixnetAccount;
                            } else {
                                NSLog(@"account:%@", error);
                            }
                        }];
    
    
    return;
    static  NSString* requestAccountURLFormat = @"https://emma.pixnet.cc/account?format=json&access_token=%@";
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:requestAccountURLFormat, self.pixnetOauth.accessToken]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    url = nil;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error){
                               if(!error) {
                                   NSDictionary* dictOfResponseData = [data objectFromJSONData];
                                   w_self.pixnetAccount = dictOfResponseData[@"account"][@"identity"];
                                   w_self.accountLabel.text = w_self.pixnetAccount;
                               } else {
                                   NSLog(@"account:%@", error);
                               }
                           }];
    
}

- (void)requestCategoriesWithUser:(NSString *)user {
    __block MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.labelText = @"取得分類...";
    [hud setRemoveFromSuperViewOnHide:YES];
    
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSString* urlString = [NSString stringWithFormat:@"http://emma.pixnet.cc/blog/categories?format=json&user=%@", user];
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    typeof(self) __weak w_self = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error){
                               if(!error) {
                                   NSDictionary* dictOfResponseData = [data objectFromJSONData];
                                   NSArray* categories = dictOfResponseData[@"categories"];
                                   for (NSDictionary* category in categories) {
                                       [w_self.categoriesOfArticle addObject:
                                        @{ @"title":category[@"name"], @"path":category[@"id"] }
                                        ];
                                   }
                                   categories = nil;
                                   dictOfResponseData = nil;
                                   
                                   [w_self.tableView reloadData];
                                   
                                   
                               } else {
                                   [[NSNotificationCenter defaultCenter] postNotificationName:RequestFailureNotification
                                                                                       object:error.description];
                               }
                               
                               [hud hide:YES afterDelay:.4f];
                           }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categoriesOfArticle.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"pixnet_cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary* dict = self.categoriesOfArticle[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    dict = nil;
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"分類";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* dict = self.categoriesOfArticle[indexPath.row];
    ArticleListViewController* listController;
    listController = [[ArticleListViewController alloc] initArticleListWithTitle:dict[@"title"]
                                                                            path:dict[@"path"]
                                                                           oauth:self.pixnetOauth];
    listController.user = kDefaultUser;
    listController.isLoginPixnet = (self.pixnetOauth!=nil);
    
    [self.navigationController pushViewController:listController animated:YES];
    listController = nil;
}


@end
