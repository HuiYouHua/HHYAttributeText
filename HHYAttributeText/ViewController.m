//
//  ViewController.m
//  HHYAttributeText
//
//  Created by 华惠友 on 2018/12/28.
//  Copyright © 2018 华惠友. All rights reserved.
//

#import "ViewController.h"
#import "YYKit.h"
#import "BGWebController.h"
#import "RegexKitLite.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet YYLabel *messageTextLabel;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, strong) NSArray *questionList;

@end

@implementation ViewController

/**
 labelText中h包含有该类样式字段
 1.a标签样式:<a href= "http://www.baidu.com\">点击这里</ a>
 2.link标签样式:1. [link submit=\"1\"]选项1[/link]<br>2. [link submit=\"2\"]选项2[/link]
 3.labelText展示完后后面跟个数组questionList换行展示
 4.可自动识别手机号和地址(eg:baidu.com)
 
 注意: 1.其中a标签, link标签, 数组字段都需标蓝并可点击,
      2.其中普通文本与标蓝文字,标蓝文字与标蓝文字可能会有重复文字
      3.a标签和link标签以及普通文本随机顺序排练, 需要按照给定的labelText先后顺序进行展示
      4.questionList放在最下部分
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    _messageTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageTextLabel.numberOfLines = 0;
    self.labelText = @"百度一下选项5<br>5. [link submit=\"5\"]选项5[/link]<br>5. [link submit=\"5\"]选项5[/link]迁入本市以外户籍迁入本市以外选项5户籍迁入本市以外户籍15056953149 网址1:http://www.baidu.com 网址2:baidu.com<a href=\"http://www.baidu.com\">百度一下</a> 我是菜单不是建议问<br>1. [link submit=\"1\"]选项1[/link]<br>2. [link submit=\"2\"]选项2[/link]迁入本市以外户籍百度一下迁入本市以外户籍迁入本市以外户籍 <a href=\"http://www.google.com\">谷歌一下</a>迁入本市以外户籍迁入本市以外户籍<a href=\"http://www.baidu.com\">百度一下</a>迁入本市以外户籍选项5百度一下";

    self.questionList = @[@"我是问题1", @"我是问题2", @"我是问题3", @"我是问题4"];

    
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self handleText:self.labelText];
}

- (void)handleText:(NSString *)text {
    
    // 修改换行符  将br 换乘\n
    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange (0, text.length)];
    
    NSString *labelText = text;
    // -------------- 筛选普通文本内容 --------------
    NSString *normalText = [self componentsSeparated:labelText startString:@"[link" endString:@"link]"];
    normalText = [self componentsSeparated:normalText startString:@"<a" endString:@"a>"];
    // -------------- 筛选普通文本内容 --------------
    
    // -------------- 处理link标签 --------------
    // 文本前面加个\n方便标签处理 后续去掉
    NSArray *textArray = [labelText componentsSeparatedByString:@"[link"];
    if ([textArray[0] rangeOfString:@"\n"].location == NSNotFound) {
        labelText = [NSString stringWithFormat:@"\n%@",labelText];
    }
    // link标签的序号
    NSArray *indexArray = [self linkBrSeparatedString:labelText];
    // 包含submit和标签体内容的二维数组
    NSArray *linkAllArray = [NSArray array];
    if ([labelText containsString:@"[link"]) {
        linkAllArray = [self componentsSeparatedLinkString:labelText];
        
        // 删除link多余字段
        labelText = [self deleteLinkString:labelText linkArray:linkAllArray];
    }
    // -------------- 处理link标签 --------------
    
    // -------------- 处理a标签 --------------
    // 包含href和标签体内容的二维数组
    NSArray *httpAllArray = [NSArray array];
    if ([labelText containsString:@"<a"]){
        NSString *regex_http = @"<a href=(?:.*?)>(.*?)<\\/a>";
        httpAllArray = [labelText arrayOfCaptureComponentsMatchedByRegex:regex_http];
        
        if (httpAllArray.count > 0) {
            // 先把html a标签都给去掉
            labelText = [labelText stringByReplacingOccurrencesOfString:@"<a href=(.*?)>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange (0, labelText.length)];
            labelText = [labelText stringByReplacingOccurrencesOfString:@"<\\/a>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange (0, labelText.length)];
        }
    }
    
    // -------------- 处理a标签 --------------
    
    // 去除首尾空行
    labelText = [labelText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.questionList.count>0) {
        labelText = [labelText stringByAppendingString:@"\n您是否想问如下问题:"];
    }
    self.messageTextLabel.text = labelText;
    NSMutableAttributedString *attrS = [[NSMutableAttributedString alloc] initWithString:labelText];
    [attrS addAttributes:[self textStyle] range:NSMakeRange(0, attrS.length)];
    
    // -------------- 给特殊文字加蓝加点击 --------------
    // link标签加蓝加点击
    __weak typeof(self) weakSelf = self;
    attrS = [self setTextBlueHandleWithText:labelText originalText:text normalText:normalText contentArray:linkAllArray attributedString:attrS tapAction:^(NSString *hrefStr, NSString *tapStr) {
        NSLog(@"tapAction:href:%@-----content:%@",hrefStr,tapStr);

    }];
    
    // a标签加蓝加点击
    attrS = [self setTextBlueHandleWithText:labelText originalText:text normalText:normalText contentArray:httpAllArray attributedString:attrS tapAction:^(NSString *hrefStr, NSString *tapStr) {
        if ([hrefStr containsString:@"\""]) {
            hrefStr = [hrefStr componentsSeparatedByString:@"\""][1];
        }
        NSLog(@"tapAction:href:%@-----content:%@",hrefStr,tapStr);
        BGWebController *webVC = [[BGWebController alloc] init];
        if (![hrefStr hasPrefix:@"http://"] && ![hrefStr hasPrefix:@"https://"]) {
            hrefStr = [@"http://" stringByAppendingString:hrefStr];
        }
        webVC.urlString = hrefStr;
        [weakSelf.navigationController pushViewController:webVC animated:YES];
    }];
    
   
    // 加上也需要标蓝的序号
    for (NSString *indexStr in indexArray) {
        NSArray *rangeArray = [self getRangeStr:labelText findText:indexStr];
        for (NSValue *value in rangeArray) {
            NSRange range = [value rangeValue];
            [attrS setColor:[UIColor blueColor] range:range];
        }
    }
    // -------------- 给特殊文字加蓝加点击 --------------
    
    // -------------- 处理链接和号码加蓝加点击 --------------
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber  error:&error];
        NSArray *detectorArray = [detector matchesInString:labelText options:0 range:NSMakeRange(0, [labelText length])];
    
        if (detectorArray.count>0) {
            // 链接和号码
            NSMutableArray *originalStrArray = [NSMutableArray new];
            for (NSTextCheckingResult *result in detectorArray) {
                NSString * originalStr =[labelText substringWithRange:result.range];
                if (originalStr) {
                    [originalStrArray addObject:originalStr];
                }
                
                __block NSTextCheckingResult *weakResult = result;
                [attrS setTextHighlightRange:result.range color:[UIColor blueColor] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                    NSString *tapString =  [text.string substringWithRange:range];
                    NSLog(@"tapAction:%@",tapString);
                
                    
                    if (weakResult) {
                        if (weakResult.resultType == NSTextCheckingTypeLink) {
                            BGWebController *webVC = [[BGWebController alloc] init];
                            if (![tapString hasPrefix:@"http://"] && ![tapString hasPrefix:@"https://"]) {
                                tapString = [@"http://" stringByAppendingString:tapString];
                            }
                            webVC.urlString = tapString;
                            [self.navigationController pushViewController:webVC animated:YES];
                        }else if(weakResult.resultType == NSTextCheckingTypePhoneNumber) {
                            NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",tapString];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                        }
                    }

                }];
            }
        }
    // -------------- 处理链接和号码加蓝加点击 --------------
    
    // -------------- questionList添加到后面 --------------
    for (int i=0; i<self.questionList.count; i++) {
        NSString *question = [NSString stringWithFormat:@"\n%@",self.questionList[i]];

        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:question];
        [att addAttributes:[self textStyle] range:NSMakeRange(0, att.length)];

        [att setTextHighlightRange:[question rangeOfString:question] color:[UIColor blueColor] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSString *tapString =  [text.string substringWithRange:range];
            NSLog(@"questiontapAction:%@",tapString);
        }];
        [attrS appendAttributedString:att];
    }
    // -------------- questionList添加到后面 --------------
    
    // 设置文本
    self.messageTextLabel.attributedText = attrS;
    

}

/**
 处理当标蓝文本与普通文本有重复的情况
 普通文字和蓝色文字有重复部分
 处理逻辑:
 1.找出重复文字在原始字符串中的位置,因为可能有多个重复,所以设置数组repeatIndexArray进行存放重复的序号
 2.因为有可能有重复文字,所以在查找标蓝文字时返回的可能不止一个结果,因此也需用数组存放range
 3.当循环存放range的数组时,当改序号跟repeatIndexArray存放的序号有相同时,则不执行该循环下面的内容,即此时所的的range为普通文字的range,不进行标蓝处理

 @param labelText 去除所有样式的完整文本
 @param originalText 原始未处理过的完整w文本
 @param normalText 去除标签文字的文本
 @param contentArray 需要处理的标签数组
 @param attrS 可变字符
 @return 可变字符
 */
- (NSMutableAttributedString *)setTextBlueHandleWithText:(NSString *)labelText originalText:(NSString *)originalText normalText:(NSString *)normalText contentArray:(NSArray *)contentArray attributedString:(NSMutableAttributedString *)attrS tapAction:(void(^)(NSString *hrefStr, NSString *tapStr))tapAction {
    // a标签加蓝加点击
    if (contentArray.count != 0) {
        for (int i=0; i<contentArray.count; i++) {
            NSArray *httpArray = contentArray[i];
            // 处理a标签内容,只保留链接地址
            NSString *urlStr = @"";
            if ([httpArray[0] containsString:@"\""]) {
                urlStr = [httpArray[0] componentsSeparatedByString:@"\""][1];
            }
            
            NSMutableArray *repeatIndexArray = [NSMutableArray array];
            if ([normalText containsString:httpArray[1]]) {
                
                NSArray *rangeArray = [self getRangeStr:originalText findText:httpArray[1]];
                for (int j=0; j<rangeArray.count; j++) {
                    NSValue *value = rangeArray[j];
                    NSRange range = [value rangeValue];
                    NSRange newRange = NSMakeRange(range.location+range.length+1, 1);
                    NSString *newStr = @"";
                    if (newRange.location<originalText.length) {
                        newStr = [originalText substringWithRange:newRange];
                    }
                    
                    if (![newStr isEqualToString:@"/"]) {
                        [repeatIndexArray addObject:@(j)];
                    }
                }
            }
            
            __block NSString *weakHrefStr = httpArray[0];
            NSArray *rangeArray = [self getRangeStr:labelText findText:httpArray[1]];
            for (int j=0; j<rangeArray.count; j++) {
                BOOL isJumpout = NO;
                if (repeatIndexArray.count>0) {
                    for (int k=0; k<repeatIndexArray.count; k++) {
                        int repeatIndex = [repeatIndexArray[k] intValue];
                        if (j == repeatIndex) {
                            isJumpout = YES;
                        }
                    }
                }
                if (isJumpout) {
                    continue;
                }
                NSValue *value = rangeArray[j];
                
                NSRange range = [value rangeValue];
                [attrS setTextHighlightRange:range color:[UIColor blueColor] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                    NSString *tapString =  [text.string substringWithRange:range];
                    tapAction(weakHrefStr, tapString);
                }];
            }
            
        }
    }
    return attrS;
}

// 获取某段字符串在文字中的位置,返回数组类型,可能查找的字段有重复
- (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText {
    
    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:3];
    if (findText == nil && [findText isEqualToString:@""]) {
        return nil;
    }
    
    NSRange rang = [text rangeOfString:findText]; //获取第一次出现的range
    if (rang.location != NSNotFound && rang.length != 0) {
        {
            [arrayRanges addObject:[NSValue valueWithRange:rang]];//将第一次的加入到数组中
            NSRange rang1 = {0,0};
            NSInteger location = 0;
            NSInteger length = 0;
            for (int i = 0;; i++) {
                if (0 == i) {
                    location = rang.location + rang.length;
                    length = text.length - rang.location - rang.length;
                    rang1 = NSMakeRange(location, length);
                } else {
                    location = rang1.location + rang1.length;
                    length = text.length - rang1.location - rang1.length;
                    rang1 = NSMakeRange(location, length);
                }
                //在一个range范围内查找另一个字符串的range
                rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
                if (rang1.location == NSNotFound && rang1.length == 0) {
                    break;
                } else {//添加符合条件的location进数组
                    [arrayRanges addObject:[NSValue valueWithRange:rang1]];
                }
            }
        }
        
        return arrayRanges;
    }
    return nil;
}

// 将某段文字截取掉
- (NSString *)componentsSeparated:(NSString *)text startString:(NSString *)startString endString:(NSString *)endString {
    while ([text containsString:startString]) {
        NSRange startRange = [text rangeOfString:startString];
        NSRange endRange = [text rangeOfString:endString];
        // 起始位置  截取的长度
        NSRange range = NSMakeRange(startRange.location, endRange.location - startRange.location+endRange.length);
        if (range.length > text.length) {
            break;
        }
        
        // 取link标签的内容
        text = [text stringByReplacingCharactersInRange:range withString:@""];;
    }
    
    return text;
}

/**
 截取类似 [link submit=\"1\"]选项1[/link] 的文本
 二元数组
 二元数组[0]: 表示submit中的内容 eg: 1
 二元数组[1]: 表示标签体的内容  eg: 选项1
 */
- (NSMutableArray *)componentsSeparatedLinkString:(NSString *)labelText{
    NSString *labelText1 = labelText;
    NSString *labelText2 = labelText;
    //    NSMutableString *mutStr = [[NSMutableString alloc] initWithString:labelText];
    
    NSMutableArray *arrayLink = [NSMutableArray array];
    NSMutableArray *submitLink = [NSMutableArray array]; // 提交的内容
    NSMutableArray *contentLink = [NSMutableArray array]; // link标签的内容
    
    while ([labelText1 containsString:@"[link submit="]) {
        NSRange startRange = [labelText1 rangeOfString:@"[link submit=\""];
        NSRange endRange = [labelText1 rangeOfString:@"\"]"];
        // 起始位置  截取的长度
        NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
        if (range.length > labelText1.length) {
            break;
        }
        // 取提交的内容
        NSString *result = [labelText1 substringWithRange:range];
        if (result.length>0) {
            [submitLink addObject:result];
        }
        
        // 取link标签的内容
        labelText1 = [labelText1 substringFromIndex:endRange.location+1];
    }
    int i = 0;
    while ([labelText2 containsString:@"[link submit="]) {
        NSRange startRange = [labelText2 rangeOfString:@"\"]"];
        NSRange endRange = [labelText2 rangeOfString:@"[/link"];
        // 起始位置  截取的长度
        NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
        if (range.length > labelText2.length) {
            break;
        }
        // 取提交的内容
        NSString *result = [labelText2 substringWithRange:range];
        if (result.length>0) {
            [contentLink addObject:result];
        }
        
        // 取link标签的内容
        labelText2 = [labelText2 substringFromIndex:endRange.location+1];
        //        DefLog(@"%@",labelText);
        i++;
    }
    //    [arrayLink addObject:submitLink];
    //    [arrayLink addObject:contentLink];
    
    for (int i=0; i<submitLink.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:submitLink[i]];
        [array addObject:contentLink[i]];
        [arrayLink addObject:array];
    }
    return arrayLink;
}

// 删除link多余字段
- (NSString *)deleteLinkString:(NSString *)labelText linkArray:(NSArray *)linkArray {
    for (int i =0; i<linkArray.count; i++) {
        labelText = [labelText stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[link submit=\"%@\"]",linkArray[i][0]] withString:@""];
        labelText =[labelText stringByReplacingOccurrencesOfString:@"\[/link]" withString:@""];
    }
    //    DefLog(@"labelText:---%@",labelText);
    
    return labelText;
}

// 获取link标签前面的序号
- (NSMutableArray *)linkBrSeparatedString:(NSString *)text {
    NSMutableArray *indexArray = [NSMutableArray array];
    
    while ([text containsString:@"\n"]) {
        NSRange startRange = [text rangeOfString:@"\n"];
        NSRange endRange = [text rangeOfString:@"[link"];
        // 起始位置  截取的长度
        NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
        if (range.length > text.length) {
            break;
        }
        // 取提交的内容
        NSString *result = [text substringWithRange:range];
        if (result.length>0) {
            [indexArray addObject:result];
        }
        
        // 取link标签的内容
        text = [text substringFromIndex:endRange.location+1];
    }
    return indexArray;
}

- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.25 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.lineSpacing = 3.0;//行间距
    return @{NSFontAttributeName: font,
             NSParagraphStyleAttributeName: style};
}

- (BOOL)containsString:(NSString *)aString
{
    NSRange range = [[aString lowercaseString] rangeOfString:[aString lowercaseString]];
    return range.location != NSNotFound;
}

//- (UIViewController *)viewController {
//    for (UIView* next = [self superview]; next; next = next.superview) {
//        UIResponder* nextResponder = [next nextResponder];
//        if ([nextResponder isKindOfClass:[UIViewController
//                                          class]]) {
//            return (UIViewController*)nextResponder;
//        }
//    }
//    return nil;
//}

@end















