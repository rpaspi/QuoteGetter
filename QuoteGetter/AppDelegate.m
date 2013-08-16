//
//  AppDelegate.m
//  QuoteGetter
//
//  Created by rpaspi on 13.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import "AppDelegate.h"
#import <dispatch/dispatch.h>

#define STOCKSYMBOL1 1
#define STOCKSYMBOL2 2
#define STOCKQUOTE1  3
#define STOCKQUOTE2  4

@interface AppDelegate () {
    id updateHandler;
}
@end

@implementation AppDelegate {
    dispatch_queue_t backgroundQueue;
}

@synthesize targetWatch = _targetWatch;
@synthesize apple = _apple;
@synthesize microsoft = _microsoft;
@synthesize google;

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
        if (self.apple) {
            [self.apple update];
            NSLog(@"Altes Apple benutzt");
        } else {
            _apple = [[Quotes alloc] initWithSymbol:@"AAPL"];
            [self.apple update];
            NSLog(@"Apple neu erstellt");
        }
        if (self.google) {
            [self.google update];
            NSLog(@"Altes Google benutzt");
        } else {
            self.google = [[Quotes alloc] initWithSymbol:@"GOOG"];
            [self.google update];
            NSLog(@"Google neu erstellt");
        }
        // Send data to watch:
        NSNumber *symbol1key = @(STOCKSYMBOL1);
        NSNumber *symbol2key = @(STOCKSYMBOL2);
        NSNumber *quote1key = @(STOCKQUOTE1);
        NSNumber *quote2key = @(STOCKQUOTE2);
        NSDictionary *update = @{ symbol1key:self.apple.symbol, symbol2key:self.google.symbol, quote1key:[self.apple getQuoteString], quote2key:[self.google getQuoteString]};
        [self.targetWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            //NSString *message = error ? [error localizedDescription] : @"Update sent!";
            //[[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
        return;
        
    }
    @catch (NSException *exception) {
    }
    [[[UIAlertView alloc] initWithTitle:nil message:@"Error parsing response" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    updateHandler = [[NSObject alloc] init];
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    // Initialize with the last connected watch:
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];

    // Override point for customization after application launch.
    backgroundQueue = dispatch_queue_create("de.rpaspi.queue", NULL);
    dispatch_async(backgroundQueue, ^{
        _apple = [[Quotes alloc] initWithSymbol:@"AAPL"];
        self.microsoft = [[Quotes alloc] initWithSymbol:@"MSFT"];
        self.google = [[Quotes alloc] initWithSymbol:@"GOOG"];
    });
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

@end
