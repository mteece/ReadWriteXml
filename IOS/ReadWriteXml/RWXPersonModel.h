//
//  RWXPersonModel.h
//  ReadWriteXml
//
//  Created by Matthew Teece on 2/26/13.
//  Copyright (c) 2013 Matthew Teece. All rights reserved.
//

#import "RWXModelBase.h"
#import "RWXUserModel.h"
#import "RWXAddressModel.h"
#import "RWXCompanyModel.h"

@interface RWXPersonModel : RWXModelBase
{
    RWXUserModel *user;
    RWXAddressModel *address;
    RWXCompanyModel *company; // Not serializable.
}

@property (nonatomic, retain) RWXUserModel *user;
@property (nonatomic, retain) RWXAddressModel *address;
@property (nonatomic, retain) RWXCompanyModel *company;
@end
