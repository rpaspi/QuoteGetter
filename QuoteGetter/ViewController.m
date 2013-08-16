//
//  ViewController.m
//  QuoteGetter
//
//  Created by privat on 13.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (strong, nonatomic) AppDelegate *delegate;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.delegate = [[AppDelegate alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)send:(id)sender {
    [self.delegate comunicateWithPebble];
}
@end
