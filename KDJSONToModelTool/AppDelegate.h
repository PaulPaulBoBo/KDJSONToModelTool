//
//  AppDelegate.h
//  KDJSONToModelTool
//
//  Created by LiuBo on 2020/3/27.
//  Copyright © 2020 LiuBo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

