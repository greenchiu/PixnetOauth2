//
//  ArticleListViewController.h
//  pixnetfunapp
//
//  Created by Green on 13/7/25.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixnetOauth2.h"
id NN(id value);

/**
 * 分類文章列表
 */
@interface ArticleListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSString* user;
@property (assign) BOOL isLoginPixnet;

- (id)initArticleListWithTitle:(NSString*)title
                          path:(NSString*)path
                         oauth:(PixnetOauth2*)oauth;

@end
