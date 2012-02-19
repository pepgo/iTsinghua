//
//  THUAccountManager.m
//  Tsinghua
//
//  Created by Xin Chen on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "THUAccountManager.h"

@implementation THUAccountManager

static THUAccountManager *defaultManager;

+ (THUAccountManager *)defaultManager
{
    if (defaultManager == nil) {
        defaultManager = [[THUAccountManager alloc] init];
    }
    return defaultManager;
}

- (void)setCurrentAccount:(NSString *)currentAccount
{
    [[NSUserDefaults standardUserDefaults] setValue:currentAccount forKey:@"current_thu_account"];
    [[NSUserDefaults standardUserDefaults] setValue:[currentAccount stringByAppendingString:@"@thu"] forKey:@"current_wiz_account"];
}

- (NSString *)currentWizAccount
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"current_wiz_account"];
}

- (NSString *)currentAccount
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"current_thu_account"];
}

- (void)setCurrentPassword:(NSString *)currentPassword
{
    [[NSUserDefaults standardUserDefaults] setValue:currentPassword forKey:@"current_usr_password"];
}

- (NSString *)currentPassword
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"current_usr_password"];
}

- (NSArray *)allAccounts
{
    NSString *applicationDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] 
                                      stringByAppendingPathComponent:@"Tsinghua"];
    NSError *error = nil;
    NSArray *accountNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationDirectory error:&error];
    if (error != nil) 
    {
        NSLog(@"THUAccountManager: error reading account names for offline visiting.");
        return nil;
    }
    return accountNames;
}

@end
