//
//  KDTool.m
//  KDJSONToModelTool
//
//  Created by LiuBo on 2020/3/27.
//  Copyright © 2020 LiuBo. All rights reserved.
//

#import "KDTool.h"

@implementation KDTool

- (NSDictionary *)getDictWithJsonString:(NSString *)jsonString finish:(void(^)(BOOL isSuccess))finish {
    jsonString = [[[[jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\t" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    /// 解析字典
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@";};" withString:@"};"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@";}" withString:@"}"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@";" withString:@","];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    NSString *regex = @"[,{].*?:";
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regular matchesInString:jsonString options:0 range:NSMakeRange(0, jsonString.length)];
    NSMutableString* jsonMuStr = [[NSMutableString alloc]initWithString:jsonString];
    int i = 1;
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        NSString *mStr = [jsonString substringWithRange:range];
        if(![mStr containsString:@"\""]){
            [jsonMuStr insertString:@"\"" atIndex:range.location + i];
            i += 2;
            [jsonMuStr insertString:@"\"" atIndex:range.location + i + range.length - 3];
        }
    }
    ///
    jsonString = [self correctErrValueWithJsonString:jsonMuStr];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        finish(NO);
        return nil;
    }
    return dic;
}

- (NSString *)correctErrValueWithJsonString:(NSString *)jsonStr{
    NSString *regex = @":.*?,";
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regular matchesInString:jsonStr options:0 range:NSMakeRange(0, jsonStr.length)];
    NSMutableString* jsonMuStr = [[NSMutableString alloc]initWithString:jsonStr];
    int i = 1;
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        NSString *mStr = [jsonStr substringWithRange:range];
        if(mStr.length > 2)
        mStr = [mStr substringWithRange:NSMakeRange(1, mStr.length - 2)];
        if(![mStr containsString:@"\""] && ![self isPureNumber:mStr] && ![mStr containsString:@"}"] && ![mStr containsString:@"["] && ![mStr containsString:@"true"] && ![mStr containsString:@"false"]){
            [jsonMuStr insertString:@"\"" atIndex:range.location + i];
            i += 2;
            [jsonMuStr insertString:@"\"" atIndex:range.location + i + range.length - 3];
        }
    }
    return jsonMuStr;
}
- (BOOL)isPureNumber:(NSString*)string{
    return [self isPureInt:string] || [self isPureFloat:string];
}
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

-(void)showTitle:(NSString *)title msg:(NSString *)msg  type:(NSAlertStyle)type window:(NSWindow *)window {
    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"确定"];
    alert.messageText = title;
    alert.informativeText = msg;
    [alert setAlertStyle:type];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

@end
