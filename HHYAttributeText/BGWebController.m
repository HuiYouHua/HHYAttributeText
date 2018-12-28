//
//  BGWebController.m
//  BusinessGo
//
//  Created by feitian on 2017/4/6.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import "BGWebController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "BGBridgeForReleaseVCJSModel.h"
#import <WebKit/WebKit.h>
#import "BGWebProgressView.h"
#import "NSDictionary+YYAdd.h"
#import "YYKit.h"
@interface BGWebController ()<UIWebViewDelegate,UIDocumentInteractionControllerDelegate,JSObjcDelegate,BGBridgeForReleaseVCJSModelDelegate>

@property (strong, nonatomic)  IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet BGWebProgressView *webProgressView;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) JSContext *jsContext;

@property (nonatomic,strong) UIBarButtonItem *backItem;
@property (nonatomic,strong) UIBarButtonItem *closeItem;
@property (nonatomic,strong) UIBarButtonItem *moreItem;
@property (nonatomic,strong) NSArray *fileTypeArray;//容纳可以点击的超链接类型


@end


@implementation BGWebController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if(self.titleString){
        self.title = [[self.titleString componentsSeparatedByString:@"."] firstObject];
    }else{
        self.title = @"";
    }
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#00a1a3"];
//   self.backItem = [SKControllerTools createBarButtonTextItemWithTarget:self action:@selector( backButtonAction:) title:@"返回" image:@"top-back" highlightImage:@"top-back"];
//    self.navigationItem.leftBarButtonItem = self.backItem;
    self.webView.delegate = self;
    self.webProgressView.lineColor = [UIColor greenColor];
    [self resetCurrentJsContext];
    
    
    if(self.urlString){
        NSLog(@"%@",self.urlString);
        //        NSString *urlString = self.urlString;
        NSString *urlString = self.urlString;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60]];
        self.webView.backgroundColor =[UIColor whiteColor];
        [self.webView setScalesPageToFit:YES];
        self.webView.scrollView.bounces = NO;
        self.webView.scrollView.showsHorizontalScrollIndicator = NO;
        self.webView.scrollView.showsVerticalScrollIndicator = NO;
        //        [self.webView reload];
    }else{
        [self showDifferentFile];
        [self.webView setScalesPageToFit:YES];
    }
}



-(void)updateNavigationBarButtonItems{
    if ([self.webView canGoBack]) {
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    } else {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItem = self.backItem;
    }
    if (self.showRightItem) {
        self.navigationItem.rightBarButtonItem = self.moreItem;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = nil;
    }
}

-(void)backButtonAction:(UIButton *)backBtn{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        [self updateNavigationBarButtonItems];
    } else {
        [self closeButtonAction:backBtn];
    }
}

-(void)closeButtonAction:(UIButton *)closeBtn{
    //清理js交互
    [BGBridgeForReleaseVCJSModel clean];
    if (self.backBlock) {
        self.backBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)moreButtonAction:(UIButton *)moreBtn{
    [self useOtherRoadToOpenTheFile];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma clang diagnostic pop

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - math
-(NSArray *)fileTypeArray{
    if (!_fileTypeArray) {
        _fileTypeArray = [[NSArray alloc]initWithObjects:@"txt",@"pdf",@"html",@"docx",@"doc",@"ppt",@"pptx",@"xls",@"xlsx",@"png",@"jpg",@"jpeg",@"bmp",@"com", nil];
    }
    return _fileTypeArray;
}
//展示不同类型的文件
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
-(void)showDifferentFile{
    if (!self.Filelocaldata) {
        return;
    }
    NSString *fileType = [[self.titleString componentsSeparatedByString:@"."] lastObject];
    if ([fileType isEqualToString:@"txt"]) {
        //utf-8解析
        NSString *body = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
        if (!body) {//gbk解析
            body = [NSString stringWithContentsOfFile:self.filePath encoding:0x80000632 error:nil];
        }
        
        if (!body) {//GB18030解析
            body = [NSString stringWithContentsOfFile:self.filePath encoding:0x80000631 error:nil];
        }
        
        if (body) {
            //替换换行符号为HTML符号;
            body =[body stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        [self.webView loadHTMLString:body baseURL:nil];
    }else if ([fileType isEqualToString:@"pdf"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"html"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"docx"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"doc"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"application/msword" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"ppt"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.ms-powerpoint" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"pptx"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.presentationml.presentation" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"xls"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.ms-excel" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"xlsx"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"png"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"image/png" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"jpg"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"image/jpg" textEncodingName:@"UTF-8" baseURL:nil];
    } else if ([fileType isEqualToString:@"jpeg"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"image/jpeg" textEncodingName:@"UTF-8" baseURL:nil];
    }else if ([fileType isEqualToString:@"bmp"]){
        [self.webView loadData:self.Filelocaldata MIMEType:@"image/bmp" textEncodingName:@"UTF-8" baseURL:nil];
    }else{
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"不支持的文件类型" message:@"不支持该类型的文件浏览，尝试用其他应用打开？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf useOtherRoadToOpenTheFile];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    if (url) {
        NSString *fileNameStr = [url lastPathComponent];
        NSString *Doc = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/localFile"] stringByAppendingPathComponent:fileNameStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:Doc atomically:YES];
        
    }
    return YES;
}

-(void)useOtherRoadToOpenTheFile{
    if (!self.filePath) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    self.documentInteractionController = [UIDocumentInteractionController
                                          interactionControllerWithURL:url];
    [self.documentInteractionController setDelegate:self];
    
    [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self updateNavigationBarButtonItems];
    [self.webProgressView startLoadingAnimation];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.webView.scalesPageToFit = YES;
    [self resetCurrentJsContext];
    [self updateNavigationBarButtonItems];
    [self.webProgressView endLoadingAnimation];
    NSLog(@"%@",webView.request.URL);
    NSString *currentURLString = [NSString stringWithFormat:@"%@",webView.request.URL];
    //URL 发生变化发送通知返回按钮 不执行pop方法
    if (![currentURLString isEqualToString:self.urlString]) {
//        [DefNotification postNotificationName:ReceiveRefreshURLStringNotificationName object:self.urlString];
    }
    
    // 获取当前网页的标题
    if (self.showTitleString == NO) {
        NSString *titleStr = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//        if ([titleStr notEmptyOrNull]) {
//            self.title = titleStr;
//            NSLog(@"%@",titleStr);
//        }
    }
    //  NSDictionary *notify =@{
    //        @"activityId": @"6",
    //        @"busiId": @"2008",
    //        @"content": @[
    //                    @{
    //                        @"fieldValue": @"深圳",
    //                        @"fieldName": @"出差地点"
    //                    },
    //                    @{
    //                        @"fieldValue": @"2018-08-22",
    //                        @"fieldName": @"出差开始时间"
    //                    },
    //                    @{
    //                        @"fieldValue": @"2018-08-31",
    //                        @"fieldName": @"出差结束时间"
    //                    }
    //                    ],
    //        @"createTime": @"2018-08-22 10:48:59",
    //        @"oprUid": @"89",
    //        @"relevantCustomers": @[
    //                              @{
    //                                  @"customerId": @"89",
    //                                  @"name": @"葛岩",
    //                                  @"avatar": @"http://172.31.21.6:37090/uploadFile/ent/1529315529906_746_750.jpg"
    //                              },
    //                              @{
    //                                  @"customerId": @"433",
    //                                  @"name": @"张帆",
    //                                  @"avatar": @"http://172.31.21.6:37090/uploadFile/ent/1517905132370_1239_1239.jpg"
    //                              }
    //                              ],
    //        @"showUrl": @"http://172.31.21.6:37090/uc-api/cc_verify.html?fid=1135",
    //        @"status": @"等待张帆审核",
    //        @"title": @"出差审批",
    //        @"toUids": @"89,433"
    //        };
    //通知转提醒
    if (self.notify) {
        NSString *getNotifyJs = [NSString stringWithFormat:@"responseNotifyMsg('%@')",[self.notify jsonStringEncoded]];
        [_webView stringByEvaluatingJavaScriptFromString:getNotifyJs];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.webProgressView endLoadingAnimation];
}

- (BOOL)canOpenType:(NSString *)typeString{
    for (NSString *str in self.fileTypeArray) {
        if (![typeString containsString:str]) {
            continue;
        }else{
            return YES;
        }
    }
    return NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    NSArray *types = [requestString componentsSeparatedByString:@"."];
    if (([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"testapp"])||([types count] > 1 && ![self canOpenType:(NSString *)[types lastObject]])) {
        //提示语
        NSString *transString = nil;
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"alert"])
        {
            transString = [NSString stringWithString:[(NSString *)[components objectAtIndex:2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
        }
        if (![self canOpenType:(NSString *)[types lastObject]]) {
            transString = @"不支持的文件类型";
        }
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"温馨提示" message:transString
                              delegate:self cancelButtonTitle:nil
                              otherButtonTitles:@"确定", nil];
        alert.delegate =self;
        [alert show];
        return NO;
    }
    
    return YES;
    
}

#pragma mark - UIWebView JS 交互

-(void)resetCurrentJsContext{
//    self.jsContext = [self.webView valueForKeyPath:BGJavaScriptContextKey];
//    BGBridgeForReleaseVCJSModel *releaseVCJSModel = [BGBridgeForReleaseVCJSModel sharedOnceModel];
//    if (self.jsCommonStr) {
//        self.jsContext[self.jsCommonStr] = releaseVCJSModel;
//    }else{
//        self.jsContext[kcommon] = releaseVCJSModel;
//    }
//    releaseVCJSModel.delegate = self;
//    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
//        context.exception = exceptionValue;
//        NSLog(@"异常信息：%@", exceptionValue);
//    };
}

-(void)skipToChatViewWithData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushToChatViewWithData:data];
    });
}
#pragma mark - 群发消息
-(void)bgMassiveMessage:(id)data{
    
}


@end
