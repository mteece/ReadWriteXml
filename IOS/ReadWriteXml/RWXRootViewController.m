//
//  RWXRootViewController.m
//  ReadWriteXml
//
//  Created by Matthew Teece on 2/19/13.
//  Copyright (c) 2013 Matthew Teece. All rights reserved.
//

#import "RWXRootViewController.h"
#import <DDXML.h>
#import <AFNetworking.h>

@interface RWXRootViewController ()

// Private methods
-(void)parseXML:(NSString*)source;
-(void)createXML;

@end

@implementation RWXRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"library" ofType:@"xml"] encoding:NSUTF8StringEncoding error:&error];
   // [self parseXML:content];
   // [self createXML];
    [self postXml];
    
}

-(void)parseXML:(NSString*)source {
    
    NSError *error = nil;
    DDXMLDocument *theDocument = [[DDXMLDocument alloc] initWithXMLString:source options:0 error:&error];
    
    NSArray *results = [theDocument nodesForXPath:@"/catalog/book[price>35]" error:&error];
    
    for (DDXMLElement *book in results) {
        
        NSLog(@"-----------");
        
        NSString *id = [[book attributeForName:@"id"] stringValue];
        
        
        NSLog(@"id:%@",id);
        
        for (int i = 0; i < [book childCount]; i++) {
            DDXMLNode *node = [book childAtIndex:i];
            NSString *name = [node name];
            NSString *value = [node stringValue];
            NSLog(@"%@:%@",name,value);
        }
    }
}

-(void)createXML
{
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:@"<addresses/>" options:0 error:nil];
    DDXMLElement *root = [document rootElement];
    [root addChild:[DDXMLNode elementWithName:@"address" stringValue:@"Some Address"]];
    
    //This will give you:
    /*
    <addresses>
    <address>Some Address</address>
    </addresses>
     */
    [document XMLStringWithOptions:DDXMLNodePrettyPrint];
     NSLog(@"%@", [document description]);
}

-(void)postXml
{
    
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:@"<addresses/>" options:0 error:nil];
    DDXMLElement *root = [document rootElement];
    [root addChild:[DDXMLNode elementWithName:@"address" stringValue:@"Some Address"]];
    
    
    NSURL *baseURL = [NSURL URLWithString:@"http://127.0.0.1:5000/xml"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[document XMLData]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
                                                                                               
                                                                                               // Initialize the XMLParser options.
                                                                                               [XMLParser setDelegate:self];
                                                                                               [XMLParser setShouldProcessNamespaces:NO];
                                                                                               [XMLParser setShouldReportNamespacePrefixes:NO];
                                                                                               [XMLParser setShouldResolveExternalEntities:NO];
                                                                                               [XMLParser parse];
                                                                                               
                                                                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XML) {
                                                                                               
                                                                                               NSString *message = [[NSString alloc] initWithFormat:@"Request failed with error: %@.", error];
                                                                                               
                                                                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed"
                                                                                                                                               message:message
                                                                                                                                              delegate:nil
                                                                                                                                     cancelButtonTitle:@"OK"
                                                                                                                                     otherButtonTitles:nil];
                                                                                               [alert show];
                                                                                               
                                                                                           }];
    [operation start];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"Parsing started, %@", [parser description]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"Element value: %@", string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}

- (void) parserDidEndDocument: (NSXMLParser *)parser
{
     NSLog(@"Parsing ended, %@", [parser description]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
