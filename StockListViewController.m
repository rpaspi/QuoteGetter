//
//  StockListViewController.m
//  QuoteGetter
//
//  Created by privat on 24.09.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import "StockListViewController.h"
#import "StockInfo.h"

@interface StockListViewController () {
    NSArray *aktien;
    NSMutableArray *aktienSymbole;
    NSInteger selectedRow;
    NSString *selectedSymbol;
}
@end

@implementation StockListViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize selectOne = _selectOne;
@synthesize pressedSlot = _pressedSlot;
@synthesize delegate = _delegate;
@synthesize filteredStockList = _filteredStockList;
@synthesize searchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    self.searchBar.delegate = self;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Custom initialization

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"StockInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    aktien = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    aktienSymbole = [NSMutableArray arrayWithCapacity:[aktien count]];
    for (StockInfo *aktie in aktien) {
        [aktienSymbole addObject:aktie.symbol];
    }
    if (self.selectOne) {
        UIButton *pressedButton = self.delegate.slots[self.pressedSlot-1];
        NSString *preselectedSymbol = pressedButton.currentTitle;
        selectedSymbol = preselectedSymbol;
    }
    // Initialize the filteredStockList with a capacity equal to the aktien-array's capacity
    self.filteredStockList = [NSMutableArray arrayWithCapacity:[aktien count]];

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        if (self.selectOne) {
            return [aktien count]+1;
        } else {
            return [aktien count];
        }
    } else {
        return [self.filteredStockList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (tableView != self.searchDisplayController.searchResultsTableView) {

        if (self.selectOne) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"None";
            } else {
                StockInfo *aktie = [aktien objectAtIndex:(indexPath.row - 1)];
                cell.textLabel.text = aktie.symbol;
                NSString *detail = aktie.name;
                cell.detailTextLabel.text = detail;
            }
            if ([cell.textLabel.text isEqualToString:selectedSymbol]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            StockInfo *aktie = [aktien objectAtIndex:indexPath.row];
            cell.textLabel.text = aktie.symbol;
            cell.detailTextLabel.text = aktie.name;
        }

    } else {
        NSLog(@"Cell updaete in search");
        StockInfo *aktie = [self.filteredStockList objectAtIndex:indexPath.row];
        cell.textLabel.text = aktie.symbol;
        cell.detailTextLabel.text = aktie.name;
        if (self.selectOne) {
            if ([aktie.symbol isEqualToString:selectedSymbol]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            NSLog(@"selected Symbol: %@", selectedSymbol);
        }
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    //<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    // [self.navigationController pushViewController:detailViewController animated:YES];
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        if (self.selectOne) {
            NSString *symbol = [[NSString alloc] init];
            if (indexPath.row == 0) {
                NSLog(@"Selected stock: None");
                symbol = @"None";
            } else {
                StockInfo *aktie = [aktien objectAtIndex:(indexPath.row - 1)];
                NSLog(@"Selected stock: %@ - %@", aktie.symbol, aktie.name);
                symbol = aktie.symbol;
            }
            selectedSymbol = symbol;
            NSLog(@"Check!");
            [[self.delegate.slots objectAtIndex:(self.pressedSlot -1)] setTitle:symbol forState:UIControlStateNormal];
            [self.tableView reloadData];
        } else {
            StockInfo *aktie = [aktien objectAtIndex:indexPath.row];
            NSLog(@"Tapped stock: %@ - %@", aktie.symbol, aktie.name);
        }
    } else {
        if (self.selectOne) {
            StockInfo *aktie = [self.filteredStockList objectAtIndex:indexPath.row];
            NSString *symbol = aktie.symbol;
            selectedSymbol = symbol;
            NSLog(@"Check!");
            NSLog(@"Tapped stock: %@ - %@", aktie.symbol, aktie.name);
            [[self.delegate.slots objectAtIndex:(self.pressedSlot -1)] setTitle:symbol forState:UIControlStateNormal];
            [tableView reloadData];
        } else {
            StockInfo *aktie = [self.filteredStockList objectAtIndex:indexPath.row];
            NSLog(@"Tapped stock: %@ - %@", aktie.symbol, aktie.name);
        }
    }
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}
 


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StockModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"QuoteGetter.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredStockList removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.symbol contains[c] %@) OR (SELF.name contains[c] %@)",searchText,searchText];
    self.filteredStockList = [NSMutableArray arrayWithArray:[aktien filteredArrayUsingPredicate:predicate]];
    NSLog(@"Searching ...");
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.tableView reloadData];
    NSUInteger row = [aktienSymbole indexOfObject:selectedSymbol];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

@end
