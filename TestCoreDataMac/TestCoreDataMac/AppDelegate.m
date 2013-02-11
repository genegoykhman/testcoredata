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
	[self refreshEntityCount:nil];
}

- (void)report:(NSString *)info
{
	NSTextStorage *storage = [_textView textStorage];
	[_textView setString:[NSString stringWithFormat:@"%@\n%@", [storage string], info]];
	NSRange bottom = NSMakeRange([[storage string] length], 0);
	[_textView scrollRangeToVisible:bottom];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	return NSTerminateNow;
}

- (void)onInsert:(id)sender
{
	[_dataController insertSimpleEntity];
}

- (void)onDeleteAll:(id)sender
{
	[_dataController deleteAllEntities];
}

- (void)onNukeAndPave:(id)sender
{
	[_dataController nukeAndPave];
}

- (void)refreshEntityCount:(id)sender
{
	[_countEntities setStringValue:[NSString stringWithFormat:@"%d", (int)[_dataController countEntities]]];
}

@end
