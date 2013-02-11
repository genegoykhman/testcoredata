//
//  AppDelegate.h
//  TestCoreDataTouch
//
//  Created by Gene Goykhman on 2013-02-10.
//  Copyright (c) 2013 Indigo Technologies Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) DataController *dataController;
- (void)report:(NSString *)info;
- (void)refreshEntityCount;

@end
