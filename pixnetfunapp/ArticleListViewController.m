//
//  ArticleListViewController.m
//  pixnetfunapp
//
//  Created by Green on 13/7/25.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "ArticleListViewController.h"
#import "JSONKit.h"

#import "ArticleViewController.h"

id NN(id value) {
    if(!value)
        return @"";
    return value;
}

@interface ArticleListViewController ()
@property (nonatomic, weak) NSString* path;
@property (nonatomic, weak) PixnetOauth2* oauth;
@property (nonatomic, strong) NSMutableArray* articles;
@property (nonatomic, strong) NSArray* filter;

/**
 * 取得文章列表, 並顯示
 */
- (void)requestArticles;
@end

@implementation ArticleListViewController

- (void)dealloc {
    self.path = nil;
    self.oauth = nil;
    self.articles = nil;
    self.filter = nil;
    self.user = nil;
    self.tableView = nil;
}

- (id)initArticleListWithTitle:(NSString *)title path:(NSString *)path oauth:(PixnetOauth2 *)oauth {
    self = [super initWithNibName:@"ArticleListViewController" bundle:nil];
    if(self) {
        self.title = title;
        self.path = path;
        self.oauth = oauth;
        self.articles = [[NSMutableArray alloc] initWithCapacity:0];
        self.filter = kArticleFilter;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self requestArticles];
    
    
    
}

- (void)requestArticles {
    
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    NSString* urlString = nil;
    
    if([self.path isKindOfClass:[NSString class]] &&
       ([self.path isEqualToString:@"hot"] || [self.path isEqualToString:@"latest"]) ) {
        urlString = [NSString stringWithFormat:@"emma.pixnet.cc/blog/articles/%@/?format=json&user=%@",
                     self.path,
                     self.user];
    } else {
        urlString = [NSString stringWithFormat:@"emma.pixnet.cc/blog/articles/?format=json&user=%@&category_id=%@",
                     self.user,
                     self.path];
    }
    
    if(self.oauth) {
        urlString = [NSString stringWithFormat:@"https://%@&access_token=%@", urlString, self.oauth.accessToken];
    } else
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    
//    NSLog(@"%@", urlString);
    
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    url = nil;
    
    typeof(self) __weak w_self = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error){
                               app.networkActivityIndicatorVisible = NO;
                               if(!error) {
                                   NSDictionary* dictOfResponseData = [data objectFromJSONData];
                                   NSArray* resultArray = dictOfResponseData[@"articles"];
//                                   NSLog(@"%@", resultArray);
                                   
                                   for (NSDictionary* dictOfArticle in resultArray) {
                                       
                                       NSString* status = dictOfArticle[@"status"];
                                       //未登入就排除隱藏好友跟草稿
                                       if(!w_self.isLoginPixnet && [w_self.filter indexOfObject:status]!=NSNotFound) {
                                           continue;
                                       }
                                       
                                       NSDictionary* simpleArticleData = @{
                                                                           @"title":dictOfArticle[@"title"],
                                                                           @"id":dictOfArticle[@"id"],
                                                                           @"status":dictOfArticle[@"status"],
                                                                           @"password_hint":NN(dictOfArticle[@"password_hint"]),
                                                                           @"thumbImage":dictOfArticle[@"thumb"],
                                                                           @"link":dictOfArticle[@"link"]
                                                                           };
                                       [w_self.articles addObject:simpleArticleData];
                                       simpleArticleData = nil;
                                   }
                                   resultArray = nil;
                                   dictOfResponseData = nil;
                                   
                                   [w_self.tableView reloadData];
                               } else {
                                   [[NSNotificationCenter defaultCenter] postNotificationName:RequestFailureNotification
                                                                                       object:error.description];
                               }
                           }];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"pixnet_cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary* dict = self.articles[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.text = dict[@"password_hint"];
    dict = nil;
    return cell;
}

#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* dict = self.articles[indexPath.row];
    ArticleViewController* avc;
    avc = [[ArticleViewController alloc] initArticleViewControllerWithData:dict
                                                                      user:self.user
                                                                     oauth:self.oauth];
    
    [self.navigationController pushViewController:avc animated:YES];
    avc = nil;
    dict = nil;
    
    
}

@end
