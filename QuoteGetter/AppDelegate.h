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

@interface AppDelegate : UIResponder <PBPebbleCentralDelegate, UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PBWatch *targetWatch;
@property (strong, nonatomic) Quotes *apple;
@property (strong, nonatomic) Quotes *microsoft;
@property (strong, nonatomic) Quotes *google;

- (void)comunicateWithPebble;

@end
