//
//  AppDelegate.h
//  TestCoreDataMac
//
//  Created by Gene Goykhman on 2013-02-10.
//  Copyright (c) 2013 Indigo Technologies Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *textView;
@property (strong, nonatomic) DataController *dataController;
@property (strong, nonatomic) IBOutlet NSTextField *countEntities;
- (IBAction)onInsert:(id)sender;
- (IBAction)onDeleteAll:(id)sender;
- (IBAction)onNukeAndPave:(id)sender;
- (void)refreshEntityCount:(id)sender;

@end
