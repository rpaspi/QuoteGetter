//
//  StockList.h
//  QuoteGetter
//
//  Created by privat on 17.08.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockList : NSObject

@property (strong, nonatomic) NSString *nasdaqFileString;

-(id) init;
-(NSString*) readFile;
@end
