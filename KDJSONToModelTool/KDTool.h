//
//  KDTool.h
//  KDJSONToModelTool
//
//  Created by LiuBo on 2020/3/27.
//  Copyright © 2020 LiuBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDTool : NSObject

- (NSDictionary *)getDictWithJsonString:(NSString *)jsonString finish:(void(^)(BOOL isSuccess))finish;
- (void)showTitle:(NSString *)title msg:(NSString *)msg  type:(NSAlertStyle)type window:(NSWindow *)window;

@end

NS_ASSUME_NONNULL_END
