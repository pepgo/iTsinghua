//
//  THUAccountManager.h
//  Tsinghua
//
//  Created by Xin Chen on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THUAccountManager : NSObject

// Return the shared instance of THUAccountManager
// @since 2.1
+ (THUAccountManager *)defaultManager;

// Set/get the current account
// @since 2.1
@property (nonatomic, strong) NSString *currentAccount;

// Get the current wiz account. The setter method will be execute automatically
// when user set the current account.
// @since 2.1
@property (nonatomic, strong, readonly) NSString *currentWizAccount;

// Set/get the current account password
// @since 2.1
@property (nonatomic, strong) NSString *currentPassword;

// Return all the account names with which the user has logged in.
// @since 2.1
@property (nonatomic, strong, readonly) NSArray *allAccounts;

@end
