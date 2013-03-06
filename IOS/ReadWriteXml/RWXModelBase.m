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

static BOOL nestChildObjects;
static NSMutableArray *knownClasses;
static NSMutableDictionary *knownProperties;

@implementation RWXModelBase

+(void) initialize
{
    nestChildObjects = NO;
    
    if(!knownClasses) {
        knownClasses = [NSMutableArray array];
    }
    
    if(!knownProperties) {
        knownProperties = [[NSMutableDictionary alloc] init];
    }
    
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
    
    NSArray *children = [element children];
    BOOL found = NO;
    for (DDXMLNode *node in children) {
        NSString *nodeName = [NSString stringWithString:[node name]];
        if ([nodeName rangeOfString:@"ssl_"].location != NSNotFound) {
            found = YES;
        } else {
            found = NO;
            break;
        }
    }
    if (!found) {
        NSLog(@"XML Parsing error: 'ssl_' prefix missing.");
        return nil;
    }
    
    if((self = [self init])) {
        
        u_int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for(i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            
            if(propName) {
                NSString *xmlPropertyName = [self serializeStringToXmlFormatedString:[NSString stringWithUTF8String:propName]];
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                NSArray *array = [element elementsForName:xmlPropertyName];
                
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
    u_int i;
    
    NSArray *allProperties = [self describe:self classType:[self class]];
    for(i = 0; i < [allProperties count]; i++) {
        NSString *propName = [NSString stringWithString:[allProperties objectAtIndex:i]];
        if(propName) {
            NSString *xmlPropertyName = [self serializeStringToXmlFormatedString:propName];
            NSString *propertyName = [NSString stringWithString:propName];
            NSValue *value = [self valueForKey:propertyName];
            
            if([value isKindOfClass:[RWXModelBase class]]) {
                [knownProperties setObject:xmlPropertyName forKey:propertyName];
                DDXMLDocument *childDoc = [((RWXModelBase *)value) objectAsDDXMLDocumentWithName:xmlPropertyName];
                DDXMLElement *childElement = [[childDoc rootElement] copy];
                
                if(nestChildObjects) {
                    [rootElement addChild:childElement];
                } else {
                    NSArray *elementChildren = [[childElement children] copy];
                    for (DDXMLNode *node in elementChildren) {
                        [node detach];
                        [rootElement addChild:node];
                    }
                }
            }
            else if (value && (id)value != [NSNull null]) {
                
                char firstChar = [propertyName characterAtIndex:0];
                if((firstChar >= 'A' && firstChar <= 'Z') || (firstChar >= 'a' && firstChar <= 'z')) {
                    [knownProperties setObject:xmlPropertyName forKey:propertyName];
                    //unicode and numbers causes occasional problems with DDXMLNode
                    DDXMLNode *node = [DDXMLNode elementWithName:xmlPropertyName stringValue:[value description]];
                    [rootElement addChild:node];
                }
            }
        }
    }
    
    return doc;
}

- (NSDictionary *) objectAsDictionary
{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    u_int i;
    
    NSArray *allProperties = [self describe:self classType:[self class]];
    for(i = 0; i < [allProperties count]; i++) {
        NSString *propName = [NSString stringWithString:[allProperties objectAtIndex:i]];
        if(propName) {
            NSString *propertyName = [NSString stringWithString:propName];
            NSValue *value = [self valueForKey:propertyName];
            
            if (value && (id)value != [NSNull null]) {
                [dict setValue:value forKey:propertyName];
            }
        }
    }
    return dict;
}

- (NSString *) serializeStringToXmlFormatedString:(NSString *)inputString
{
    int index = 0;
    NSMutableString *mutableInputString = [NSMutableString stringWithString:inputString];
    NSMutableString *appenedString = [[NSMutableString alloc] init];
    
    while (index < mutableInputString.length) {
        
        unichar uc = [mutableInputString characterAtIndex:index];
        NSString *currentChar = [NSString stringWithCharacters:&uc length:1];
        
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[mutableInputString characterAtIndex:index]]) {
            NSString *shift =  [NSString stringWithString:currentChar];
            [appenedString appendString:@"_"];
            [appenedString appendString:[shift lowercaseString]];
            index++;
        } else {
            [appenedString appendString:currentChar];
            index++;
        }
    }
    
    [appenedString insertString:@"ssl_" atIndex:0];
    
    return [NSString stringWithString:appenedString];
}

- (NSString *) dserializeStringFromXmlFormatedString:(NSString *)inputString
{
    int index = 0;
    NSMutableString *mutableInputString = [NSMutableString stringWithString:[inputString substringFromIndex:3]];
    NSMutableString *appenedString = [[NSMutableString alloc] init];
    
    while (index < mutableInputString.length) {
        
        unichar uc = [mutableInputString characterAtIndex:index];
        NSString *currentChar = [NSString stringWithCharacters:&uc length:1];
        
        if ([[NSCharacterSet characterSetWithCharactersInString:@"_"] characterIsMember:[mutableInputString characterAtIndex:index]]) {
            NSString *shift =  [NSString stringWithString:currentChar];
            [appenedString appendString:[shift uppercaseString]];
            index++;
        } else {
            [appenedString appendString:currentChar];
            index++;
        }
    }
    
    return [NSString stringWithString:appenedString];

}

- (NSArray *) describe:(id)instance classType:(Class)classType
{
    NSUInteger count;
    objc_property_t *propList = class_copyPropertyList(classType, &count);
    NSMutableArray *propArray = [[NSMutableArray alloc] init];
    
    for ( int i = 0; i < count; i++ )
    {
        objc_property_t property = propList[i];
        
        const char *propName = property_getName(property);
        NSString *propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        
        if(propName)
        {
            //id value = [instance valueForKey:propNameString];
            //NSLog(@"%@=%@ ; ", propNameString, value);
            [propArray addObject:propNameString];
        }
    }
    free(propList);
    
    Class superClass = class_getSuperclass( classType );
    if ( superClass != nil && ! [superClass isEqual:[NSObject class]] )
    {
        NSArray *superArray = [self describe:instance classType:superClass];
        for(int i = 0; i < [superArray count]; i++) {
            [propArray addObject:superArray[i]];
        }
    }
    return propArray;
}


@end
