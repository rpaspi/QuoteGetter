//
//  Quotes.h
//  CommTest
//
//  Created by privat on 09.07.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quotes : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSNumber *last;
@property (nonatomic, strong) NSNumber *change;
@property (nonatomic, strong) NSNumber *percentageChange;
@property (nonatomic, strong) NSString *currentTag;
@property (nonatomic, strong) NSString *oldTag;
@property (nonatomic, strong) NSXMLParser *parser;

- (void) update;
- (Quotes*) initWithSymbol:(NSString*) quoteSymbol;

// Parser Delegate Methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (NSString*) getQuoteString;
@end
