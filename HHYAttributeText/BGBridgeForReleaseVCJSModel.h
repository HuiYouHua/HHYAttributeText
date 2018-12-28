//
//  BGBridgeForReleaseVCJSModel.h
//  BusinessUCSDK
//
//  Created by 潘弘 on 2018/7/10.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class UIWebView;
@protocol JSObjcDelegate <JSExport>//(此处为尖括号)这是个协议

-(void)skipToChatViewWithData:(id)data;
-(void)bgSkipToDetailActivityWithData:(id)data;
-(void)bgSkipToChatWithData:(id)data;
-(void)toChat:(id)data;
-(void)toModify:(id)data;
-(void)bgCloseWebView:(id)data;
-(void)bgMassiveMessage:(id)data;
-(void)cancelRelationship:(id)data;
- (void)alertCancelAndConfirm:(id)data;

@end

@protocol BGBridgeForReleaseVCJSModelDelegate <NSObject>//这是个代理
-(void)refreshWebViewWith:(id)data;//刷新webView的URL
-(void)pushToChatViewCreateBiz:(id)data;//跳转聊天打标记
-(void)pushToChatViewWithData:(id)data;
-(void)bgPushToDetailActivityWithData:(id)data;
-(void)bgPushToChatWithData:(id)data;
-(void)bgCloseWebView:(id)data;
-(void)bgMassiveMessage:(id)data;
-(void)bgcancelRelationship:(id)data;
- (void)alertCancelAndConfirm:(id)data;
@end

//jsContext桥接模型，作用：为了释放控制器
@interface BGBridgeForReleaseVCJSModel : NSObject<JSObjcDelegate>
@property (nonatomic, weak) id<BGBridgeForReleaseVCJSModelDelegate> delegate;
@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIWebView *webView;

+(instancetype)sharedOnceModel;

+(void)clean;

@end
