//
//  RWXModelBase.m
//  ReadWriteXml
//
//  Created by Matthew Teece on 2/26/13.
//  Copyright (c) 2013 Matthew Teece. All rights reserved.
//

#import "RWXModelBase.h"
#import <objc/runtime.h>
#import <DDXML.h>

Class property_getClass( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
    
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
    
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';
    
    NSMutableString *prop = [[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding] mutableCopy];
    [prop replaceOccurrencesOfString:@"T@" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [prop length])];
    [prop replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [prop length])];
    
	return ( NSClassFromString(prop) );
}

static NSMutableArray *knownClasses;

@implementation RWXModelBase

+(void) initialize
{    
    if(!knownClasses)
        knownClasses = [NSMutableArray array];
}

+(void) registerKnownClass:(Class) class
{    
    [knownClasses addObject:class];
}

+ (NSArray *) objectAsArray
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    u_int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char* name = property_getName(property);
        NSString* actualName = [NSString stringWithUTF8String:name];
        [keys addObject:actualName];
    }
    return keys;
}

- (id) initWithXMLString:(NSString *) xmlString {
    
    NSError *error = nil;
    DDXMLElement *xmlElement = [[[DDXMLDocument alloc] initWithXMLString:xmlString options:0 error:&error] rootElement];
    
    if(!xmlElement) {
        
        NSLog(@"XML Parsing error: %@", error);
        return nil;
    }
    return [self initWithDDXMLElement:xmlElement];
}

- (id) initWithDDXMLElement:(DDXMLElement *) element
{
    if(element == nil) return nil;
    if((self = [self init])) {
        
        u_int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for(i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            
            if(propName) {
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                NSArray *array = [element elementsForName:propertyName];
                
                id value = nil;
                if([array count] > 0)
                    value = [array objectAtIndex:0];
                
                Class class = property_getClass(property);
                if([knownClasses containsObject:class]) {
                    
                    value = [[class alloc] initWithDDXMLElement:value];
                    [self setValue:value forKey:propertyName];
                } else {
                    
                    [self setValue:[value stringValue] forKey:propertyName];
                }
            }
        }
    }
    
    return self;
}

- (DDXMLDocument *) objectAsDDXMLDocument {
    
    return [self objectAsDDXMLDocumentWithName:NSStringFromClass([self class])];
}

- (DDXMLDocument *) objectAsDDXMLDocumentWithName:(NSString*) name {
    
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:[NSString stringWithFormat:@"<%@/>", name]
                                                          options:0
                                                            error:nil];
    DDXMLElement *rootElement = [doc rootElement];
    u_int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSValue *value = [self valueForKey:propertyName];
            
            if([value isKindOfClass:[RWXModelBase class]]) {
                
                DDXMLDocument *childDoc = [((RWXModelBase *)value) objectAsDDXMLDocumentWithName:propertyName];
                DDXMLElement *childElement = [[childDoc rootElement] copy];
                [rootElement addChild:childElement];
            }
            else if (value && (id)value != [NSNull null]) {
                
                char firstChar = [propertyName characterAtIndex:0];
                if((firstChar >= 'A' && firstChar <= 'Z') || (firstChar >= 'a' && firstChar <= 'z')) {
                    //unicode and numbers causes occasional problems with DDXMLNode
                    DDXMLNode *node = [DDXMLNode elementWithName:propertyName stringValue:[value description]];
                    [rootElement addChild:node];
                }
            }
        }
    }
    
    free(properties);
    return doc;
}

- (NSDictionary *) objectAsDictionary {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    u_int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSValue *value = [self valueForKey:propertyName];
            
            if (value && (id)value != [NSNull null]) {
                [dict setValue:value forKey:propertyName];
            }
        }
    }
    free(properties);
    
    return dict;
}

@end
