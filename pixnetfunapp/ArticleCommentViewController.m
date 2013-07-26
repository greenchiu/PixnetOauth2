//
//  ArticleCommentViewController.m
//  pixnetfunapp
//
//  Created by Green on 13/7/25.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "ArticleCommentViewController.h"
#import "JSONKit.h"

#import "ArticleCommentRowCell.h"

@interface ArticleCommentViewController ()
@property (nonatomic, weak) UIActivityIndicatorView* indicator;
@property (nonatomic, weak) NSString* user;
@property (nonatomic, weak) NSDictionary* articleData;
@property (nonatomic, weak) PixnetOauth2* oauth;

@property (nonatomic, strong) NSMutableArray* comments;

- (void)requestArticleComments;
@end

@implementation ArticleCommentViewController

- (void)dealloc {
    self.password = nil;
    self.indicator = nil;
    self.user = nil;
    self.articleData = nil;
    self.comments = nil;
}

- (id)initWithUser:(NSString *)user article:(NSDictionary *)articleData oauth:(PixnetOauth2 *)oauth {
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        self.title = @"留言";
        self.user = user;
        self.articleData = articleData;
        self.oauth = oauth;
        self.comments = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestArticleComments];
}

#pragma mark -
- (void)requestArticleComments {
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
//    [self.indicator startAnimating];
    
    NSString* status = self.articleData[@"status"];
    
    NSString* urlString = [NSString stringWithFormat:@"emma.pixnet.cc/blog/comments?format=json&user=%@&article_id=%@",
                           kDefaultUser,
                           self.articleData[@"id"]];
    /**
     * 是否需要密碼
     */
    if([status isEqualToString:@"3"]) {
        urlString = [NSString stringWithFormat:@"%@&article_password=%@", urlString, self.password];
    }
    
    /**
     * 判斷是否是可能需要使用access_token的狀態
     */
    NSArray* filter = kArticleFilter;
    if([filter indexOfObject:status] != NSNotFound) {
        urlString = [NSString stringWithFormat:@"https://%@&access_token=%@", urlString, self.oauth.accessToken];
    } else {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    filter = nil;
    
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    url = nil;
    
    typeof(self) __weak w_self = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error){
                               [w_self.indicator stopAnimating];
                               if(!error) {
                                   NSDictionary* dictOfResponseData = [data objectFromJSONData];
//                                   NSLog(@"comment1:%@", dictOfResponseData);
                                   w_self.title = [NSString stringWithFormat:@"留言(%@)", dictOfResponseData[@"total"]];
                                   
                                   NSArray* response_comments = dictOfResponseData[@"comments"];
                                   
                                   UIFont* tempFont = [UIFont systemFontOfSize:16.f];
                                   CGSize size = CGSizeMake(280, 900);
                                   
                                   for (NSDictionary* comment in response_comments) {
                                       CGFloat height = 0;
                                       NSString* body = comment[@"body"];
                                       CGSize textSize = [body sizeWithFont:tempFont
                                                          constrainedToSize:size];
                                       height = textSize.height;

                                       [w_self.comments addObject:@{
                                            @"author":comment[@"author"],
                                            @"time":comment[@"created_at"],
                                            @"comment":body,
                                            @"height":[NSNumber numberWithFloat:height]
                                        }];
                                       
                                   }
                                   [w_self.tableView reloadData];
                               } else {
                                   [[NSNotificationCenter defaultCenter] postNotificationName:RequestFailureNotification
                                                                                       object:error.description];
                               }
                               app.networkActivityIndicatorVisible = NO;
                           }];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArticleCommentCell";
    ArticleCommentRowCell *cell = (ArticleCommentRowCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ArticleCommentRowCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary* dict = self.comments[indexPath.row];
    
    [cell loadData:dict];
//    cell.textLabel.text = dict[@"body"];
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [self.comments[indexPath.row][@"height"] floatValue];
    height += (26 + 13); //(top, bottom)
    height = MAX(60, height);
    return height;
}

@end
