//
//  RWXRootViewController.h
//  ReadWriteXml
//
//  Created by Matthew Teece on 2/19/13.
//  Copyright (c) 2013 Matthew Teece. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWXRootViewController : UIViewController

-(IBAction)postXml:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationBar *uiNavigationBar;
@property (weak, nonatomic) IBOutlet UIButton *uiPostXmlButton;
@property (weak, nonatomic) IBOutlet UITextView *uiResponseOutput;

@end
