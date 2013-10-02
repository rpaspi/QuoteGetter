//
//  StockList.m
//  QuoteGetter
//
//  Created by privat on 17.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import "StockList.h"

@interface StockList ()
- (NSString*) downloadFile;
static void writeCallback( CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo);
void callbackFunction(CFReadStreamRef stream, CFStreamEventType event, void* myPtr);

@end

@implementation StockList
@synthesize nasdaqFileString = _nasdaqFileString;

-(id) init {
    if (self = [super init]) {
        self.nasdaqFileString = [self readFile];
    }
    return self;
}

-(NSString*) readFile {
    // NSString *filePathNasdaqListed = [[NSBundle mainBundle] pathForResource:@"nasdaqlisted" ofType:@"txt"];
    // NSString *nasdaqListed = [NSString stringWithContentsOfFile:filePathNasdaqListed encoding:NSUTF8StringEncoding error:nil];
    // NSString *filePathOtherListed = [[NSBundle mainBundle] pathForResource:@"otherlisted" ofType:@"txt"];
    // NSString *otherListed = [NSString stringWithContentsOfFile:filePathOtherListed encoding:NSUTF8StringEncoding error:nil];
    //return [NSString stringWithFormat:@"%@\n%@", nasdaqListed, otherListed];
    return [self downloadFile];
}

- (NSString*) downloadFile {
    NSURL *url = [NSURL URLWithString:@"ftp://anonymous@ftp.nasdaqtrader.com/SymbolDirectory/nasdaqlisted.txt"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSString *liste = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return liste;
}

@end
