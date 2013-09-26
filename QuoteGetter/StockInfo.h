//
//  StockInfo.h
//  QuoteGetter
//
//  Created by privat on 24.09.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StockInfo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * symbol;

@end
