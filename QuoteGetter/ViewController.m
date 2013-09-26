//
//  ViewController.m
//  QuoteGetter
//
//  Created by privat on 13.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "StockListViewController.h"

@interface ViewController ()
@property (strong, nonatomic) AppDelegate *delegate;

@end

@implementation ViewController
@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize slots = _slots;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.slots = @[self.slot1, self.slot2, self.slot3, self.slot4];
    self.delegate = [[AppDelegate alloc] initWithView:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)send:(id)sender {
    [self.delegate comunicateWithPebble];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    StockListViewController *stockList = segue.destinationViewController;
    if (![segue.identifier isEqualToString:@"show"]) {
        UIView *button = (UIView*)sender;
        stockList.selectOne = YES;
        stockList.pressedSlot = button.tag;
        stockList.delegate = self;
    } else {
        stockList.delegate = nil;
        stockList.selectOne = NO;
        stockList.pressedSlot = 0;
    }
}

- (IBAction)showStocks:(id)sender {
    NSLog(@"HIER!!!");
}

- (IBAction)updateDB:(id)sender {
    [self.delegate updateDataBase];
}

- (IBAction)changeSlot:(UIView*)sender {
    NSLog(@"Pressed Button %ld", (long)sender.tag);
    StockListViewController *stockList = [[StockListViewController alloc] initWithStyle:UITableViewStylePlain];
    stockList.selectOne = YES;
    stockList.pressedSlot = sender.tag;
    stockList.delegate = self;
    [self.navigationController pushViewController:stockList animated:YES];
}
@end
