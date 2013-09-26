//
//  StockListViewController.h
//  QuoteGetter
//
//  Created by privat on 24.09.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ViewController.h"

@interface StockListViewController : UITableViewController <UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property Boolean selectOne;
@property NSInteger pressedSlot;
@property (strong, nonatomic) ViewController *delegate;
@property (strong,nonatomic) NSMutableArray *filteredStockList;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
