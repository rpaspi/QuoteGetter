//
//  AppDelegate.m
//  QuoteGetter
//
//  Created by rpaspi on 13.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import "AppDelegate.h"
#import <dispatch/dispatch.h>
#import "ViewController.h"
#import "StockInfo.h"

#define STOCKSYMBOL1 1
#define STOCKSYMBOL2 2
#define STOCKQUOTE1  3
#define STOCKQUOTE2  4
#define NUMBEROFSLOTS 4

@interface AppDelegate () {
    id updateHandler;
}

- (void) clearDataBase:(Boolean)full fromEntity:(NSString*) entityDescription;
@end

@implementation AppDelegate {
    dispatch_queue_t backgroundQueue;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize controller = _controller;

@synthesize targetWatch = _targetWatch;
@synthesize apple = _apple;
@synthesize microsoft = _microsoft;
@synthesize google;
@synthesize nasdaqListe = _nasdaqListe;
@synthesize slots = _slots;
@synthesize quotes = _quotes;

- (void)setTargetWatch:(PBWatch*)watch {
    _targetWatch = watch;
    
    // NOTE:
    // For demonstration purposes, we start communicating with the watch immediately upon connection,
    // because we are calling -appMessagesGetIsSupported: here, which implicitely opens the communication session.
    // Real world apps should communicate only if the user is actively using the app, because there
    // is one communication session that is shared between all 3rd party iOS apps.
    
    // Test if the Pebble's firmware supports AppMessages / Weather:
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            // Configure our communications channel to target the weather app:
            // See demos/feature_app_messages/weather.c in the native watch app SDK for the same definition on the watch's end:
            uint8_t bytes[] = {0x46, 0xC8, 0x8D, 0xEC, 0xBB, 0xB7, 0x40, 0xB4, 0xAB, 0xC3, 0x3E, 0x34, 0x5B, 0x87, 0x54, 0xC7};
            NSData *uuid = [NSData dataWithBytes:bytes length:sizeof(bytes)];
            [watch appMessagesSetUUID:uuid];
            updateHandler = [_targetWatch appMessagesAddReceiveUpdateHandler:^(PBWatch *watch, NSDictionary *update) {
                //NSLog(@"Update incoming ...");
                return YES;}];
            
            
            NSString *message = [NSString stringWithFormat:@"Yay! %@ supports AppMessages :D", [watch name]];
            [[[UIAlertView alloc] initWithTitle:@"Connected!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            
            NSString *message = [NSString stringWithFormat:@"Blegh... %@ does NOT support AppMessages :'(", [watch name]];
            [[[UIAlertView alloc] initWithTitle:@"Connected..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)comunicateWithPebble {
    _targetWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    
    if (self.targetWatch == nil || [self.targetWatch isConnected] == NO) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No connected watch!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    @try {
        NSMutableDictionary *update_1 = [NSMutableDictionary dictionary];
        NSMutableDictionary *update_2 = [NSMutableDictionary dictionary];
        int i = 0;
        for (UIButton* button in self.slots) {
            NSString *symbol = button.currentTitle;
            [self.quotes removeObjectAtIndex:i];
            [self.quotes insertObject:[[Quotes alloc] initWithSymbol:symbol] atIndex:i];
            [self.quotes[i] update];
            NSNumber *symbolKey = @(i+1);
            NSNumber *quoteKey = @([symbolKey intValue] + NUMBEROFSLOTS);
            NSMutableDictionary *update = [NSMutableDictionary dictionary];
            if (i < 2) {
                update = update_1;
            } else {
                update = update_2;
            }
            if ([symbol isEqualToString:@"NONE"]) {
                update[symbolKey] = @"";
            } else {
                update[symbolKey] = symbol;
            }
            update[quoteKey] = [self.quotes[i] getQuoteString];
            i++;
        }
        NSLog(@"%@", update_1);
        NSLog(@"%@", update_2);

        [self.targetWatch appMessagesPushUpdate:update_1 onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            //NSString *message = error ? [error localizedDescription] : @"Update sent!";
            //[[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [self.targetWatch appMessagesPushUpdate:update_2 onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
                //NSString *message = error ? [error localizedDescription] : @"Update sent!";
                //[[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }];
        
        return;
        
    }
    @catch (NSException *exception) {
    }
    [[[UIAlertView alloc] initWithTitle:nil message:@"Error parsing response" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (id) initWithView:(ViewController *)view {
    self = [super init];
    self.controller = view;
    self.controller.managedObjectContext = self.managedObjectContext;
    self.slots = self.controller.slots;
    self.quotes = [[NSMutableArray alloc] init];
    for (UIButton* button in self.slots) {
        [self.quotes addObject:@""];
    }

    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //ViewController *controller = (ViewController *)self.window.rootViewController;
    // NSArray *viewControllers = self.window.rootViewController.navigationController.viewControllers;
    // ViewController *controller = (ViewController *)[viewControllers objectAtIndex:viewControllers.count - 2];
    

    updateHandler = [[NSObject alloc] init];
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    // Initialize with the last connected watch:
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.targetWatch appMessagesRemoveUpdateHandler:updateHandler];
    updateHandler = nil;
    [self.targetWatch closeSession:^{}];
 }

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

// Delete database entries by either deleting one by one (full == NO) or by simply deleting the db-file
- (void) clearDataBase:(Boolean)full fromEntity:(NSString*) entityDescription
{
    if (full) {
        // Delete entire db-file
        NSArray *stores = [self.persistentStoreCoordinator persistentStores];
        NSError *error = nil;
        
        for(NSPersistentStore *store in stores) {
            [self.persistentStoreCoordinator removePersistentStore:store error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
            //Make new persistent store for future saves   (Taken From Above Answer)
            if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:store.URL options:nil error:&error]) {
                // do something with the error
            }
        }
    } else {
        // Delete items one-by-one
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *managedObject in items) {
            [self.managedObjectContext deleteObject:managedObject];
            NSLog(@"%@ object deleted",entityDescription);
        }
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
        }

    }
}

// Update the database
- (void) updateDataBase
{
    
    // Read in the list of NASDAQ noted stocks
    
    backgroundQueue = dispatch_queue_create("de.rpaspi.queue", NULL);
    
    dispatch_async(backgroundQueue, ^{
        NSError *error = nil;
        // Delete old database
        [self clearDataBase:YES fromEntity:@"StockInfo"];
        
        // Read text file with stock list from NASDAQ
        self.nasdaqListe = [[StockList alloc] init];
        NSArray *zeilen = [[self.nasdaqListe readFile] componentsSeparatedByString:@"\n"];
        NSRegularExpression *regex_symbol = [NSRegularExpression regularExpressionWithPattern:@"([A-Z]*)" options:0 error:NULL];
        
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        /*
        //Check wether object already exists in database
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"StockInfo" inManagedObjectContext:context]];
        NSArray *results = [context executeFetchRequest:request error:&error];
        NSMutableArray *results_symbols = [[NSMutableArray alloc] init];
        for (StockInfo *stock in results) {
            [results_symbols addObject:stock.symbol];
        }
        */
        
        // Add stocks to database using Core Data
        Boolean firstLine = YES; // Skip first line of text file
        for (NSString *zeile in zeilen) {
            if (!firstLine) {
                NSTextCheckingResult *match_symbol = [regex_symbol firstMatchInString:zeile options:0 range:NSMakeRange(0, [zeile length])];
                NSString *symbol = [NSString stringWithString:[zeile substringWithRange:[match_symbol range]]];
                
                // Boolean alreadyExists = [results_symbols containsObject:symbol];
                Boolean alreadyExists = NO;
                if (!alreadyExists) {
                    NSRegularExpression *regex_name = [NSRegularExpression regularExpressionWithPattern:@"[^\\|]{5,}" options:0 error:NULL];
                    NSTextCheckingResult *match_name = [regex_name firstMatchInString:zeile options:0 range:NSMakeRange(0, [zeile length])];
                    NSString *name = [NSString stringWithString:[zeile substringWithRange:[match_name range]]];
                    
                    StockInfo *aktie = [NSEntityDescription insertNewObjectForEntityForName:@"StockInfo" inManagedObjectContext:context];
                    aktie.name = name;
                    aktie.symbol = symbol;
                    // NSLog(@"Saving stock: %@ - %@\n", symbol, name);
                    
                    if (![context save:&error]) {
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                }
            }
            firstLine = NO;
        }
    });
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
