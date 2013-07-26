//
//  FBPublishViewController.h
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBPublishViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView* inputTextView;
@property (nonatomic, weak) IBOutlet UIImageView* thumbImageView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* descriptView;

/**
 * 建立 FBPublishViewController 實體
 *
 * @param data Article基本的部份資料
 * @param description Article的部分本文 ...
 */
- (id)initWithArticleData:(NSDictionary*)data description:(NSString*)description;

/**
 * bj4
 */
- (void)setArticleData:(NSDictionary*)data description:(NSString*)description __deprecated;

/**
 * 處理回到上一頁
 */
- (IBAction)handleCancel;

/**
 * 將文章發表到FB上
 */
- (IBAction)handlePublishToFacebook;
@end
