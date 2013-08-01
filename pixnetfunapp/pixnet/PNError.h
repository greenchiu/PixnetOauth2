//
//  PNError.h
//  pixnetfunapp
//
//  Created by Green on 13/7/29.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const PixnetSDKDomain;

typedef NS_ENUM(NSInteger, PixnetErrorCode) {
    /**
     * when use need oauth request and the oauth is nil, error code will return PixnetErrorInvalid
     */
    PixnetErrorInvalid = 1000,
    
    /**
     * when process the oauth, user cancel the oauth action. the handler error code will return PixnetOauthErrorCancel
     */
    PixnetOauthErrorCancel = 1001,
    
    /**
     * params data type error 、 lose value or set nil params for request, the error code will return 
     * PixnetGrantTokenErrorParamsters.
     */
    PixnetGrantTokenErrorParamsters = 2000
};

extern NSString* const PixnetErrorOauthInvalid;

extern NSString* const PixnetErrorUserCancelOauth;

//extern NSString* const PixnetErrorOauthTimeOut;

/**
 * when grant the grant token current error, the error domain will be PixnetErrorGrantToken
 */
extern NSString* const PixnetErrorGrantToken;