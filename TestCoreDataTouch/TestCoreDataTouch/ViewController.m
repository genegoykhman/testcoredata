//
//  ViewController.m
//  TestCoreDataTouch
//
//  Created by Gene Goykhman on 2013-02-10.
//  Copyright (c) 2013 Indigo Technologies Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)report:(NSString *)info
{
	[_textView setText:[NSString stringWithFormat:@"%@\n%@", [_textView text], info]];
}

@end
