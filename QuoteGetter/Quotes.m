//
//  Quotes.m
//  CommTest
//
//  Created by privat on 09.07.13.
//  Copyright (c) 2013 rpaspi. All rights reserved.
//

#import "Quotes.h"
#import "StockQuoteSvc.h"

@implementation Quotes

@synthesize symbol = _symbol;
@synthesize last = _last;
@synthesize change = _change;
@synthesize percentageChange = _percentageChange;
@synthesize currentTag = _currentTag;
@synthesize oldTag = _oldTag;
@synthesize parser = _parser;

- (Quotes*) initWithSymbol:(NSString*) quoteSymbol {
    self = [super init];
    if (self != nil) {
        self.currentTag = @"";
        self.oldTag = @"";
        self.last = @(0);
        self.change = @(0);
        self.percentageChange = @(0);
        self.symbol = [NSString stringWithString:quoteSymbol];
        if ([self.symbol isEqualToString:@"NONE"]) {
            self.symbol = @"";
        }
        [self update];
    }
    return self;
}

- (void) update {
    if (![self.symbol isEqualToString:@""]) {
        StockQuoteSoap12Binding *binding = [[StockQuoteSoap12Binding alloc] initWithAddress:@"http://www.webservicex.net/stockquote.asmx?WSDL"];
        StockQuoteSvc_GetQuote *parameters = [[StockQuoteSvc_GetQuote alloc] init];
        parameters.symbol = self.symbol;
        StockQuoteSoap12BindingResponse *response = [[StockQuoteSoap12BindingResponse alloc] init];
        //StockQuoteSvc_GetQuoteResponse
        response = [binding GetQuoteUsingParameters:parameters];
        NSArray *ergebnisse = [NSArray arrayWithArray:response.bodyParts];
        if ([ergebnisse count] > 0) {
            NSString *quoteResult = [NSString stringWithString:((StockQuoteSvc_GetQuoteResponse*)ergebnisse[0]).GetQuoteResult];
            if (!_parser) {
                self.parser =[[NSXMLParser alloc] initWithData:[quoteResult dataUsingEncoding:NSUTF8StringEncoding]];
                [self.parser setDelegate:self];
            } else {
                [self.parser abortParsing];
                self.parser = [self.parser initWithData:[quoteResult dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [self.parser parse];
        }
    }
}

- (NSString*) getQuoteString {
    if ([self.symbol isEqualToString:@""]) {
        return @"";
    } else {
        NSString *quoteString = [NSString stringWithFormat:@"%.2f %+.2f", [self.last floatValue], [self.change floatValue]];
        return quoteString;
    }
}

// Parser Delegate Methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"Last"] || [elementName isEqualToString:@"Change"] || [elementName isEqualToString:@"PercentageChange"]) {
        self.currentTag = elementName;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (![self.oldTag isEqualToString:self.currentTag]) {
        if ([self.currentTag isEqualToString:@"Last"]) {
            self.last = @([string floatValue]);
        } else if ([self.currentTag isEqualToString:@"Change"]) {
            self.change = @([string floatValue]);
        } else if ([self.currentTag isEqualToString:@"PercentageChange"]) {
            self.percentageChange = @([string floatValue]);
        }
        self.oldTag = self.currentTag;
    }
}










@end
