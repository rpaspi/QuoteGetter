//
//  ViewController.h
//  QuoteGetter
//
//  Created by privat on 13.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *slot1;
@property (weak, nonatomic) IBOutlet UIButton *slot2;
@property (weak, nonatomic) IBOutlet UIButton *slot3;
@property (weak, nonatomic) IBOutlet UIButton *slot4;
@property (strong, nonatomic) NSArray *slots;

- (IBAction)send:(id)sender;
- (IBAction)showStocks:(id)sender;
- (IBAction)updateDB:(id)sender;
- (IBAction)changeSlot:(id)sender;

@end
