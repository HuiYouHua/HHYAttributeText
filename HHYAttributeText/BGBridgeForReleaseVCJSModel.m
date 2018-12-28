//
//  BGBridgeForReleaseVCJSModel.m
//  BusinessUCSDK
//
//  Created by 潘弘 on 2018/7/10.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "BGBridgeForReleaseVCJSModel.h"

@implementation BGBridgeForReleaseVCJSModel

+(instancetype)sharedOnceModel{
    static BGBridgeForReleaseVCJSModel* model;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[BGBridgeForReleaseVCJSModel alloc] init];
    });
    return model;
}

-(void)skipToChatViewWithData:(id)data{
    if ([self.delegate respondsToSelector:@selector(pushToChatViewWithData:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate pushToChatViewWithData:data];
        });
        
    }
}
-(void)toChat:(id)data{
    if ([self.delegate respondsToSelector:@selector(pushToChatViewCreateBiz:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate pushToChatViewCreateBiz:data];
        });
    }
}
-(void)toModify:(id)data{
    if ([self.delegate respondsToSelector:@selector(refreshWebViewWith:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate refreshWebViewWith:data];
        });
    }
}
-(void)bgSkipToDetailActivityWithData:(id)data{
    if ([self.delegate respondsToSelector:@selector(bgPushToDetailActivityWithData:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate bgPushToDetailActivityWithData:data];
        });
        
    }
}
-(void)bgMassiveMessage:(id)data{
    if ([self.delegate respondsToSelector:@selector(bgMassiveMessage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate bgMassiveMessage:data];
        });
    }
}
-(void)cancelRelationship:(id)data{
    if ([self.delegate respondsToSelector:@selector(bgcancelRelationship:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate bgcancelRelationship:data];
        });
    }
}

-(void)alertCancelAndConfirm:(id)data{
    if ([self.delegate respondsToSelector:@selector(alertCancelAndConfirm:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate alertCancelAndConfirm:data];
        });
    }
}

-(void)bgSkipToChatWithData:(id)data{
    if ([self.delegate respondsToSelector:@selector(bgPushToChatWithData:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.delegate bgPushToChatWithData:data];
        });
    }
}
-(void)bgCloseWebView:(id)data{
    if ([self.delegate respondsToSelector:@selector(bgCloseWebView:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate bgCloseWebView:data];
        });
    }
}

+(void)clean{
    [BGBridgeForReleaseVCJSModel sharedOnceModel].jsContext = nil;
    [BGBridgeForReleaseVCJSModel sharedOnceModel].webView = nil;
    [BGBridgeForReleaseVCJSModel sharedOnceModel].delegate = nil;
}

@end
