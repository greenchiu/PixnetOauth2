//
//  ArticleCommentViewController.h
//  pixnetfunapp
//
//  Created by Green on 13/7/25.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixnetOauth2.h"

/**
 * 顯示回文內容, 並無做完整呈現的部份
 */
@interface ArticleCommentViewController : UITableViewController
@property (nonatomic, weak) NSString* password; ///< 如果文章需要password ...
- (id)initWithUser:(NSString*)user article:(NSDictionary*)articleData oauth:(PixnetOauth2*)oauth;

@end
