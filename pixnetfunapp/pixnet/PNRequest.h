//
//  PNRequest.h
//  pixnetfunapp
//
//  Created by Green on 13/7/29.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PNRequestCompletedHandler)(NSDictionary* data, NSError* error);

@class PixnetOauth2;
@interface PNRequest : NSObject

+ (void)requestOauthUserWithOauth:(PixnetOauth2*)oauth completedHandler:(PNRequestCompletedHandler)handler;

/**
 * @param oauth oauth could be nil, if set the oauth, the request will add param key access_token. 
 */
- (id)initWithOauth:(PixnetOauth2*)oauth;

@end
