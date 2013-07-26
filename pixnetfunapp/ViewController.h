//
//  ViewController.h
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UILabel* accountLabel;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;
@property (nonatomic, weak) IBOutlet UIButton* fblogin;
@property (nonatomic, weak) IBOutlet UILabel* fbaccountLabel;

/**
 * 開始 Pixnet Oauth
 */
- (IBAction)requestOauth;

/**
 * 登入 facebook
 */
- (IBAction)loginFb;
@end
