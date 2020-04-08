//
//  RootViewController.m
//  KDJSONToModelTool
//
//  Created by LiuBo on 2020/3/27.
//  Copyright © 2020 LiuBo. All rights reserved.
//

#import "RootViewController.h"
#import "KDTool.h"

@interface RootViewController ()

@property (weak) IBOutlet NSTextField *modelTF;
@property (weak) IBOutlet NSTextField *baseModelTF;
@property (weak) IBOutlet NSTextField *preTF;
@property (weak) IBOutlet NSTextField *keyTF;
@property (weak) IBOutlet NSTextField *jsonTF;
@property (unsafe_unretained) IBOutlet NSTextView *hTV;
@property (unsafe_unretained) IBOutlet NSTextView *mTV;

@property (nonatomic, strong) KDTool *tool;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)transBtnAction:(NSButton *)sender {
    self.hTV.string = @"";
    self.mTV.string = @"";
    NSString *jsonStr = self.jsonTF.stringValue;
    if(!jsonStr.length){
        [self.tool showTitle:@"错误提示" msg:@"JSON 字符串长度为0！" type:(NSAlertStyleWarning) window:[self.view window]];
        return;
    }
    NSDictionary *resultDic = [self.tool getDictWithJsonString:jsonStr finish:^(BOOL isSuccess) {
        
    }];
    if(![resultDic isKindOfClass:[NSDictionary class]]) {
        self.jsonTF.stringValue = [NSString stringWithFormat:@"请输入JSON字典\n当前数据类型为:%@", [resultDic class]];
    }
    NSString *fileName = self.modelTF.stringValue.length == 0 ? self.modelTF.placeholderString : self.modelTF.stringValue;
    NSString *baseName = self.baseModelTF.stringValue.length == 0 ? self.baseModelTF.placeholderString : self.baseModelTF.stringValue;
    NSString *h = [self createSingleModelHWithDic:resultDic name:fileName baseClassName:baseName hasProtocol:NO];
    NSString *m = [self createSingleModelMWithDic:resultDic name:fileName hasProtocol:NO];
    self.hTV.string = h==nil?@"JSON转Model失败":h;
    self.mTV.string = m==nil?@"JSON转Model失败":m;
}

- (IBAction)copyHBtnAction:(NSButton *)sender {
    if(self.hTV.string.length > 0) {
        [self pasteString:self.hTV.string];
        [self.tool showTitle:@"成功" msg:@".h文件内容拷贝成功" type:(NSAlertStyleInformational) window:[self.view window]];
    } else {
        [self.tool showTitle:@"失败" msg:@".h文件内容为空" type:(NSAlertStyleWarning) window:[self.view window]];
    }
}

- (IBAction)exportHBtnAction:(NSButton *)sender {
    NSMutableString *msg = [NSMutableString new];
    NSString *hFileName = [NSString stringWithFormat:@"%@.h", self.modelTF.stringValue.length == 0 ? self.modelTF.placeholderString : self.modelTF.stringValue];
    if(self.hTV.string.length > 0) {
        [self writeToFile:self.hTV.string fileName:hFileName finish:^(BOOL isSuccess, NSString *path) {
            if(isSuccess) {
                [msg appendFormat:@"%@ 导出成功！\n", hFileName];
                [self.tool showTitle:@"导出" msg:msg type:(NSAlertStyleInformational) window:[self.view window]];
            }
        }];
    } else {
        [msg appendFormat:@"JSON 字符串长度为0！"];
        [self.tool showTitle:@"导出" msg:msg type:(NSAlertStyleInformational) window:[self.view window]];
    }
}

- (IBAction)copyMBtnAction:(NSButton *)sender {
    if(self.mTV.string.length > 0) {
        [self pasteString:self.mTV.string];
        [self.tool showTitle:@"成功" msg:@".m文件内容拷贝成功" type:(NSAlertStyleInformational) window:[self.view window]];
    } else {
        [self.tool showTitle:@"失败" msg:@".m文件内容为空" type:(NSAlertStyleWarning) window:[self.view window]];
    }
}

- (IBAction)exportMBtnAction:(NSButton *)sender {
    NSMutableString *msg = [NSMutableString new];
    NSString *mFileName = [NSString stringWithFormat:@"%@.m", self.modelTF.stringValue.length == 0 ? self.modelTF.placeholderString : self.modelTF.stringValue];
    if(self.mTV.string.length > 0) {
        [self writeToFile:self.mTV.string fileName:mFileName finish:^(BOOL isSuccess, NSString *path) {
            if(isSuccess) {
                [msg appendFormat:@"%@ 导出成功！\n", mFileName];
                [self.tool showTitle:@"导出" msg:msg type:(NSAlertStyleInformational) window:[self.view window]];
            }
        }];
    } else {
        [msg appendFormat:@"JSON 字符串长度为0！"];
        [self.tool showTitle:@"导出" msg:msg type:(NSAlertStyleInformational) window:[self.view window]];
    }
}

#pragma mark - self

-(NSString *)createSingleModelHWithDic:(NSDictionary *)dic name:(NSString *)name baseClassName:(NSString *)baseClassName hasProtocol:(BOOL)hasProtocol {
    NSString *preName = self.preTF.stringValue.length == 0 ? self.preTF.placeholderString : self.preTF.stringValue;
    NSString *keyword = self.keyTF.stringValue.length == 0 ? self.keyTF.placeholderString : self.keyTF.stringValue;
    NSArray *keywords = [keyword componentsSeparatedByString:@","];
    NSMutableString *mStr = [NSMutableString new];
    NSMutableArray *arrayClasses = [NSMutableArray new];
    NSMutableArray *dicClasses = [NSMutableArray new];
    NSArray *allKeys = [dic allKeys];
    NSArray *allValue = [dic allValues];
    for (int i = 0; i < allKeys.count; i++) {
        id obj = [allValue objectAtIndex:i];
        id key = [allKeys objectAtIndex:i];
        NSString *tmpStr = @"";
        if([obj isKindOfClass:[NSString class]]) {
            NSString *tmpObj = [NSString stringWithFormat:@"%@", obj];
            if([tmpObj rangeOfString:@"-"].length > 0 &&
               [tmpObj rangeOfString:@"T"].length > 0 &&
               [tmpObj rangeOfString:@"Z"].length > 0) {
                NSString *transKey = [self checkKeyIsAble:key prefixStr:preName unableKeys:keywords];
                tmpStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@; //\n",[NSDate class], transKey];
            } else {
                NSString *transKey = [self checkKeyIsAble:key prefixStr:preName unableKeys:keywords];
                tmpStr = [NSString stringWithFormat:@"@property (nonatomic, copy  ) %@ *%@; //\n",[NSString class], transKey];
            }
        } else if([[NSString stringWithFormat:@"%@", [obj class]] isEqual:@"__NSCFBoolean"]) {
            NSString *transKey = [self checkKeyIsAble:key prefixStr:preName unableKeys:keywords];
            tmpStr = [NSString stringWithFormat:@"@property (nonatomic, assign) BOOL %@; //\n", transKey];
        } else if([obj isKindOfClass:[NSNumber class]]) {
            NSString *transKey = [self checkKeyIsAble:key prefixStr:preName unableKeys:keywords];
            tmpStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@; //\n",[NSNumber class], transKey];
        } else if([obj isKindOfClass:[NSArray class]]) {
            NSArray *arr = obj;
            if(arr.count > 0) {
                if([[arr objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                    tmpStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@<%@Model> *%@; //\n",[NSArray class], [self upperFirstChar:key], key];
                    [arrayClasses addObject:@{key:obj}];
                } else {
                    tmpStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@; //\n",[NSArray class], key];
                }
            } else {
                tmpStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@; //\n",[NSArray class], key];
            }
        } else if([obj isKindOfClass:[NSDictionary class]]) {
            NSString *dicName = [NSString stringWithFormat:@"%@%@", [self upperFirstChar:name], [self upperFirstChar:key]];
            tmpStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@; //\n", dicName, key];
            [dicClasses addObject:@{dicName:obj}];
        } else {
            NSString *transKey = [self checkKeyIsAble:key prefixStr:preName unableKeys:keywords];
            tmpStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@; //\n",@"id", transKey];
        }
        [mStr appendString:tmpStr];
    }
    NSString *levelFirstMStr = [self insertPropertyToFileFormat:[mStr copy] fileName:name baseClassName:baseClassName hasProtocol:hasProtocol];
    NSMutableString *subArrayStr = [NSMutableString new];
    if(arrayClasses.count > 0) {
        for (int i = 0; i < arrayClasses.count; i ++) {
            NSDictionary *dic = [arrayClasses objectAtIndex:i];
            NSArray *allKeys = [dic allKeys];
            NSArray *allValue = [dic allValues];
            for (int j = 0; j < allKeys.count; j++) {
                if(allValue.count > 0) {
                    if([[allValue objectAtIndex:0] isKindOfClass:[NSArray class]]) {
                        if([[[allValue objectAtIndex:0] objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                            [subArrayStr appendString:[self createSingleModelHWithDic:[[allValue objectAtIndex:0] objectAtIndex:0] name:[self upperFirstChar:[allKeys objectAtIndex:0]] baseClassName:baseClassName hasProtocol:YES]];
                        }
                    }
                }
            }
        }
    }
    if(subArrayStr.length > 0) {
        [subArrayStr appendString:@"\n"];
    }
    NSMutableString *subDicStr = [NSMutableString new];
    if(dicClasses.count > 0) {
        for (int i = 0; i < dicClasses.count; i ++) {
            NSDictionary *dic = [dicClasses objectAtIndex:i];
            NSArray *allKeys = [dic allKeys];
            NSArray *allValue = [dic allValues];
            for (int j = 0; j < allKeys.count; j++) {
                if(allValue.count > 0) {
                    if([[allValue objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                        [subDicStr appendString:[self createSingleModelHWithDic:[allValue objectAtIndex:0] name:[allKeys objectAtIndex:0] baseClassName:baseClassName hasProtocol:NO]];
                    }
                }
            }
        }
    }
    if(subDicStr.length > 0) {
        [subDicStr appendString:@"\n"];
    }
    return [NSString stringWithFormat:@"%@%@%@", subArrayStr, subDicStr, levelFirstMStr];
}

-(NSString *)checkKeyIsAble:(NSString *)key prefixStr:(NSString *)prefix unableKeys:(NSArray *)unableKeys {
    if(unableKeys != nil && unableKeys.count > 0) {
        BOOL isAble = YES;
        for (int i = 0; i < unableKeys.count; i++) {
            if([[key uppercaseString] isEqual:[unableKeys[i] uppercaseString]]) {
                isAble = NO;
                break;
            }
        }
        if(isAble) {
            return key;
        } else {
            return [NSString stringWithFormat:@"%@_%@", prefix, key];
        }
    } else {
        return key;
    }
}

-(NSString *)insertPropertyToFileFormat:(NSString *)propertyStr fileName:(NSString *)fileName baseClassName:(NSString *)baseClassName hasProtocol:(BOOL)hasProtocol {
    if(hasProtocol) {
        return [NSString stringWithFormat:@"/// <#Description#>\n@protocol %@Model<NSObject>\n@end\n@interface %@Model : %@\n\n%@\n@end\n", fileName, fileName, baseClassName, propertyStr];
    } else {
        return [NSString stringWithFormat:@"/// <#Description#>\n@interface %@ : %@\n\n%@\n@end\n", fileName, baseClassName, propertyStr];
    }
}

#pragma mark - m文件
-(NSString *)createSingleModelMWithDic:(NSDictionary *)dic name:(NSString *)name hasProtocol:(BOOL)hasProtocol {
    NSString *preName = self.preTF.stringValue.length == 0 ? self.preTF.placeholderString : self.preTF.stringValue;
    NSString *keyword = self.keyTF.stringValue.length == 0 ? self.keyTF.placeholderString : self.keyTF.stringValue;
    NSArray *keywords = [keyword componentsSeparatedByString:@","];
    NSMutableArray *arrayClasses = [NSMutableArray new];
    NSMutableArray *dicClasses = [NSMutableArray new];
    NSMutableDictionary *disableKeyDic = [NSMutableDictionary new];
    NSArray *allKeys = [dic allKeys];
    NSArray *allValue = [dic allValues];
    for (int i = 0; i < allKeys.count; i++) {
        id obj = [allValue objectAtIndex:i];
        id key = [allKeys objectAtIndex:i];
        if([obj isKindOfClass:[NSString class]]) {
            NSString *transKey = [self checkKeyIsAble:key prefixStr:preName unableKeys:keywords];
            if(![transKey isEqual:key]) {
                [disableKeyDic setObject:key forKey:transKey];
            }
        } else if([obj isKindOfClass:[NSArray class]]) {
            [arrayClasses addObject:@{key:obj}];
        } else if([obj isKindOfClass:[NSDictionary class]]) {
            NSString *dicName = [NSString stringWithFormat:@"%@%@", [self upperFirstChar:name], [self upperFirstChar:key]];
            [dicClasses addObject:@{dicName:obj}];
        } else {
            NSString *transKey = [self checkKeyIsAble:key prefixStr:preName unableKeys:keywords];
            if(![transKey isEqual:key]) {
                [disableKeyDic setObject:key forKey:transKey];
            }
        }
    }
    if(hasProtocol) {
        name = [NSString stringWithFormat:@"%@Model", name];
    }
    NSString *implementationStr = [self insertKeyMaperDic:disableKeyDic fileName:name];
    NSMutableString *subArrayStr = [NSMutableString new];
    if(arrayClasses.count > 0) {
        for (int i = 0; i < arrayClasses.count; i ++) {
            NSDictionary *dic = [arrayClasses objectAtIndex:i];
            NSArray *allKeys = [dic allKeys];
            NSArray *allValue = [dic allValues];
            for (int j = 0; j < allKeys.count; j++) {
                if(allValue.count > 0) {
                    if([[allValue objectAtIndex:0] isKindOfClass:[NSArray class]]) {
                        if([[[allValue objectAtIndex:0] objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                            [subArrayStr appendString:[self createSingleModelMWithDic:[[allValue objectAtIndex:0] objectAtIndex:0] name:[allKeys objectAtIndex:0] hasProtocol:YES]];
                        }
                    }
                }
            }
        }
    }
//    if(subArrayStr.length > 0) {
//        [subArrayStr appendString:@"\n"];
//    }
    NSMutableString *subDicStr = [NSMutableString new];
    if(dicClasses.count > 0) {
        for (int i = 0; i < dicClasses.count; i ++) {
            NSDictionary *dic = [dicClasses objectAtIndex:i];
            NSArray *allKeys = [dic allKeys];
            NSArray *allValue = [dic allValues];
            for (int j = 0; j < allKeys.count; j++) {
                if(allValue.count > 0) {
                    if([[allValue objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                        [subDicStr appendString:[self createSingleModelMWithDic:[allValue objectAtIndex:0] name:[allKeys objectAtIndex:0] hasProtocol:NO]];
                    }
                }
            }
        }
    }
//    if(subDicStr.length > 0) {
//        [subDicStr appendString:@"\n"];
//    }
    return [NSString stringWithFormat:@"%@%@%@",subArrayStr, subDicStr, implementationStr];
}

-(NSString *)insertKeyMaperDic:(NSDictionary *)dic fileName:(NSString *)fileName {
    if(dic != nil && [dic allKeys].count > 0) {
        NSMutableString *dicStr = [NSMutableString new];
        NSArray *allKeys = [dic allKeys];
        NSArray *allValue = [dic allValues];
        if(allKeys.count == 1) {
            id key = [allKeys objectAtIndex:0];
            id value = [allValue objectAtIndex:0];
            [dicStr appendFormat:@"@{@\"%@\":@\"%@\"}", key, value];
        } else {
            for (int i = 0; i < allKeys.count; i++) {
                id key = [allKeys objectAtIndex:i];
                id value = [allValue objectAtIndex:i];
                if(i == 0) {
                    [dicStr appendFormat:@"@{@\"%@\":@\"%@\",", key, value];
                } else if(i == allKeys.count-1) {
                    [dicStr appendFormat:@"@\"%@\":@\"%@\"}", key, value];
                } else {
                    [dicStr appendFormat:@"@\"%@\":@\"%@\",", key, value];
                }
            }
        }
        return [NSString stringWithFormat:@"\n/// <#Description#>\n@implementation %@ \n\n+ (JSONKeyMapper *)keyMapper {\n    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:%@];\n}\n\n@end\n", [self upperFirstChar:fileName], dicStr];
    } else {
        return [NSString stringWithFormat:@"\n/// <#Description#>\n@implementation %@ \n\n@end\n", [self upperFirstChar:fileName]];
    }
}


#pragma mark - tool
-(NSString *)upperFirstChar:(NSString *)str {
    NSString *resultStr;
    if(str && str.length > 0) {
        resultStr = [str stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[str substringToIndex:1] capitalizedString]];
    }
    return resultStr;
}

-(void)writeToFile:(NSString *)string fileName:(NSString *)fileName finish:(void(^)(BOOL isSuccess, NSString *path))finish{
    if (@available(macOS 10.12, *)) {
        [[NSFileManager defaultManager].homeDirectoryForCurrentUser startAccessingSecurityScopedResource];
        NSSavePanel *savePanel = [self savePanelWithTitleMessage:@"保存文件"
                                                       setPrompt:@"保存"
                                                        setTitle:@"保存文件"
                                                  nameFiledValue:fileName
                                               createDirectories:YES
                                          bSelectHiddenExtension:NO
                                                 andDirectoryURL:[NSFileManager defaultManager].homeDirectoryForCurrentUser
                                                AllowedFileTypes:@[]];
        [savePanel beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse result) {
            if(result == NSModalResponseOK) {
                NSURL *url = savePanel.URL;
                if(url != nil) {
                    NSLog(@"%@", url.absoluteString);
                    NSString *path = [NSString stringWithFormat:@"%@", url.path];
                    BOOL isSubccess = [[NSFileManager defaultManager] createFileAtPath:path contents:[string dataUsingEncoding:(NSUTF8StringEncoding)] attributes:nil];
                    if(isSubccess) {
                        BOOL isWrite = [[string dataUsingEncoding:(NSUTF8StringEncoding)] writeToFile:path atomically:YES];
                        if(isWrite) {
                            if(finish) {
                                finish(YES, path);
                            }
                        }
                    }
                }
            } else {
                if(finish) {
                    finish(NO, @"");
                }
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

-(NSSavePanel *)savePanelWithTitleMessage:(NSString *)ttMessage
                                setPrompt:(NSString *)prompt
                                 setTitle:(NSString *)title
                           nameFiledValue:(NSString *)fileName
                        createDirectories:(BOOL)bCreateDirc
                   bSelectHiddenExtension:(BOOL)bSelectHiddenExtension
                          andDirectoryURL:(NSURL *)dirURL
                         AllowedFileTypes:(NSArray *)fileTypes
{
    [dirURL bookmarkDataWithOptions:(NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:@[@"CFString", @"CFData"] relativeToURL:dirURL error:nil];
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setMessage:ttMessage];
    [panel setPrompt:prompt];
    [panel setAllowedFileTypes:fileTypes];
    [panel setCanCreateDirectories : bCreateDirc];
    [panel setCanSelectHiddenExtension : bSelectHiddenExtension];
    [panel setTitle:title];
    [panel setNameFieldStringValue:fileName];
    [panel setDirectoryURL:dirURL];
    
    return panel;
}

- (void)pasteString:(NSString *)str {
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    [paste clearContents];
    [paste writeObjects:@[str]];
}


#pragma mark - lazy
-(KDTool *)tool {
    if(_tool == nil) {
        _tool = [[KDTool alloc] init];
    }
    return _tool;
}


@end
