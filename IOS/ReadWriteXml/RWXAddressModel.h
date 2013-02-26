//
//  RWXAddressModel.h
//  ReadWriteXml
//
//  Created by Matthew Teece on 2/26/13.
//  Copyright (c) 2013 Matthew Teece. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWXModelBase.h"

@interface RWXAddressModel : RWXModelBase
{
    NSString *streetName;
    NSString *postalCode;
    int postNumber;
    NSDate *dateCreated;
}

@property (nonatomic, readwrite, copy) NSString *streetName;
@property (nonatomic, readwrite, copy) NSString *postalCode;
@property (nonatomic, readwrite) int postNumber;
@property (nonatomic, readwrite, strong) NSDate *dateCreated;

@end
