//
//  AppDelegate.h
//  QuoteGetter
//
//  Created by privat on 13.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

@interface AppDelegate : UIResponder <PBPebbleCentralDelegate, UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PBWatch *targetWatch;

- (void)comunicateWithPebble;

@end
