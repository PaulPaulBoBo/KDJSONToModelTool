//
//  RootWindowController.m
//  KDJSONToModelTool
//
//  Created by LiuBo on 2020/3/27.
//  Copyright © 2020 LiuBo. All rights reserved.
//

#import "RootWindowController.h"

#import "RootViewController.h"

@interface RootWindowController ()

@end

@implementation RootWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.contentViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
}

@end
