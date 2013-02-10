//
//  ViewController.h
//  TestCoreDataTouch
//
//  Created by Gene Goykhman on 2013-02-10.
//  Copyright (c) 2013 Indigo Technologies Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (assign) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *countEntities;
@property (strong, nonatomic) DataController *dataController;

- (void)report:(NSString *)info;
- (IBAction)onInsert:(id)sender;
- (IBAction)onDeleteAll:(id)sender;

@end
