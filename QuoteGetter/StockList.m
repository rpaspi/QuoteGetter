//
//  StockList.m
//  QuoteGetter
//
//  Created by privat on 17.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import "StockList.h"

@implementation StockList
@synthesize nasdaqFileString = _nasdaqFileString;

-(id) init {
    if (self = [super init]) {
        self.nasdaqFileString = [self readFile];
    }
    return self;
}

-(NSString*) readFile {
    NSString *filePathNasdaqListed = [[NSBundle mainBundle] pathForResource:@"nasdaqlisted" ofType:@"txt"];
    NSString *nasdaqListed = [NSString stringWithContentsOfFile:filePathNasdaqListed encoding:NSUTF8StringEncoding error:nil];
    NSString *filePathOtherListed = [[NSBundle mainBundle] pathForResource:@"otherlisted" ofType:@"txt"];
    NSString *otherListed = [NSString stringWithContentsOfFile:filePathOtherListed encoding:NSUTF8StringEncoding error:nil];
    //return [NSString stringWithFormat:@"%@\n%@", nasdaqListed, otherListed];
    return nasdaqListed;
}


@end
