//
//  RWXUserModel.h
//  ReadWriteXml
//
//  Created by Matthew Teece on 2/26/13.
//  Copyright (c) 2013 Matthew Teece. All rights reserved.
//

#import "RWXModelBase.h"

@interface RWXUserModel : RWXModelBase
{
    NSString *firstName;
    NSString *lastName;
}

@property (nonatomic, readwrite, copy) NSString *firstName;
@property (nonatomic, readwrite, copy) NSString *lastName;

@end
