//
//  FBPublishViewController.m
//  pixnetfunapp
//
//  Created by Green on 13/7/24.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "FBPublishViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FBManager.h"
#import "MBProgressHUD.h"

@interface FBPublishViewController () <UIAlertViewDelegate>

/**
 * 文章基本資訊
 * 包含title, link, thumb 等等資訊
 */
@property (nonatomic, weak) NSDictionary* articleData;

/**
 * 要貼到facebook's descript ...
 * 內容先抓文章的html XD
 */
@property (nonatomic, weak) NSString* description;

/**
 * 載入資料
 */
- (void)loadData;

/**
 * 處理登入
 */
- (void)handleFBManagerNotification:(NSNotification*)notify;
@end

@implementation FBPublishViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.articleData = nil;
    self.description = nil;
    self.descriptView = nil;
    self.thumbImageView = nil;
    self.inputTextView = nil;
    self.titleLabel = nil;
}

- (id)initWithArticleData:(NSDictionary *)data description:(NSString *)description {
    self = [super initWithNibName:@"FBPublishViewController" bundle:nil];
    if(self) {
        self.articleData = data;
        self.description = description;
        
        
        
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(handleFBManagerNotification:)
                       name:FBManagerRequestMeSuccessedNotification
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(handleFBManagerNotification:)
                       name:FBManagerRequestFailuredNotification
                     object:nil];
        
    }
    return self;
}

- (void)setArticleData:(NSDictionary *)articleData
           description:(NSString *)description {
    self.articleData = articleData;
    self.description = description;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadData];
}

- (void)handleCancel {
    [self dismissViewControllerAnimated:YES
                             completion:^{}];
}

- (void)handlePublishToFacebook {
    
    if(![FBManager isLogin]) {
        [FBManager login];
        
        return;
    }
    
    __block MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.labelText = @"發佈中";
    
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    NSMutableDictionary* params = [@{
                                   @"link" : self.articleData[@"link"],
                                   @"picture" : self.articleData[@"thumbImage"],
                                   @"name" : self.articleData[@"title"],
                                   @"caption" : @"this is from pixnetfunapp",
                                   @"description" : self.description,
                                   @"message":self.inputTextView.text
                                    } mutableCopy];
    
    typeof(self) __weak w_self = self;
    FacebookPostToFeedHandler handler = ^(id result, NSError* error) {
        
        if(!error) {
            
            [hud hide:NO];
            
            NSLog(@"%@", result);
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"pixnetfunapp"
                                                                message:@"發佈成功"
                                                               delegate:w_self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            alertView.tag = 2300;
            [alertView show];
            alertView = nil;
            
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"失敗";
            [hud show:NO];
            [hud hide:YES afterDelay:0.3];
        }
    };
    [FBManager postToFeedWithParamsters:params
                                handler:handler];
}

#pragma mark - private method
- (void)loadData {
    [self.thumbImageView setImageWithURL:[NSURL URLWithString:self.articleData[@"thumbImage"]]];
    self.titleLabel.text = self.articleData[@"title"];
    self.descriptView.text = self.description;
}

- (void)handleFBManagerNotification:(NSNotification *)notify {
    if([notify.name isEqualToString:FBManagerRequestMeSuccessedNotification]) {
        
        [[[UIAlertView alloc] initWithTitle:@"pixnetfunapp"
                                    message:@"登入完成, 請重新發佈"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"pixnetfunapp"
                                   message:notify.object
                                  delegate:self
                         cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 2300) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissalert" object:nil];
}

@end
