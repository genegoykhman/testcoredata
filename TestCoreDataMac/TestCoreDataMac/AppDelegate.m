//
//  AppDelegate.m
//  TestCoreDataMac
//
//  Created by Gene Goykhman on 2013-02-10.
//  Copyright (c) 2013 Indigo Technologies Ltd. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self report:@"Welcome to TestCoreDataMac"];
	[self setDataController:[[DataController alloc] initWithDelegate:self]];
	[_dataController loadPersistentStores];
	[self refreshEntityCount];
}

- (void)report:(NSString *)info
{
	NSTextStorage *storage = [_textView textStorage];
	[_textView setString:[NSString stringWithFormat:@"%@\n%@", [storage string], info]];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	return NSTerminateNow;
}

- (void)onInsert:(id)sender
{
	[_dataController insertSimpleEntity];
}

- (void)onDeleteAll:(id)insert
{
	[_dataController deleteAllEntities];
}

- (void)refreshEntityCount
{
}

@end
