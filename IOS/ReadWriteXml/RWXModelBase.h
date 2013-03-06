//
//  RWXModelBase.h
//  ReadWriteXml
//
//  Created by Matthew Teece on 2/26/13.
//  Copyright (c) 2013 Matthew Teece. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDXML.h>

@interface RWXModelBase : NSObject

@property (strong, nonatomic) NSString* personType;
@property (strong, nonatomic) NSString* personId;

+ (NSArray *) objectAsArray;
+ (void) initialize;
+ (void) registerKnownClass:(Class) class;
- (id) initWithXMLString:(NSString*) xmlString;
- (id) initWithDDXMLElement:(DDXMLElement*) element;
- (DDXMLDocument *) objectAsDDXMLDocument;
- (DDXMLDocument *) objectAsDDXMLDocumentWithName:(NSString* ) name;
- (NSDictionary *) objectAsDictionary;
- (NSString *) serializeStringToXmlFormatedString:(NSString *) inputString;
- (NSString *) dserializeStringFromXmlFormatedString:(NSString *) inputString;
- (NSArray *) describe:(id)instance classType:(Class)classType;
@end
