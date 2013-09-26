//
//  AppDelegate.h
//  QuoteGetter
//
//  Created by privat on 13.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>
#import "Quotes.h"
#import "StockList.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <PBPebbleCentralDelegate, UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PBWatch *targetWatch;
@property (strong, nonatomic) Quotes *apple;
@property (strong, nonatomic) Quotes *microsoft;
@property (strong, nonatomic) Quotes *google;
@property (strong, nonatomic) StockList *nasdaqListe;
@property (strong, nonatomic) NSArray *slots;
@property (strong, nonatomic) NSMutableArray *quotes;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) ViewController *controller;

- (void)comunicateWithPebble;
- (NSURL *)applicationDocumentsDirectory;
- (void) updateDataBase;
- (id) initWithView:(ViewController *)view;
@end
