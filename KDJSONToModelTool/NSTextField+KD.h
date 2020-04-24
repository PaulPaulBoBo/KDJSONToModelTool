//
//  NSTextField+KD.h
//  KDJSONToModelTool
//
//  Created by dzj on 2020/4/13.
//  Copyright © 2020 LiuBo. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTextField (KD)

- (BOOL)performKeyEquivalent:(NSEvent *)event;

@end

NS_ASSUME_NONNULL_END
