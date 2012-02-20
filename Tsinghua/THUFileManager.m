//
//  THUFileManager.m
//  Tsinghua
//
//  Created by Xin Chen on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "THUFileManager.h"


@interface THUFileManager ()

@property (strong, nonatomic) NSString *currentFolderName;
@property (strong, nonatomic) NSString *currentFolderDir;

// /Documents/Tsinghua
// @since 2.1
- (NSString *)applicationDirectory;

// /Documents/Tsinghua/YourAccount/
// @since 2.1
- (NSString *)currentAccountDirectory;

// @since 2.1
- (NSString *)accountDirectory:(NSString *)account;

@end



@implementation THUFileManager

@synthesize currentFolderDir;
@synthesize currentFolderName;


static THUFileManager *defaultManager = nil;

+ (THUFileManager *)defaultManager
{
    if (defaultManager == nil) {
        defaultManager = [[THUFileManager alloc] init];
    }
    return defaultManager;
}

- (NSString *)applicationDirectory
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] 
            stringByAppendingPathComponent:@"Tsinghua"];
}

- (NSString *)currentAccountDirectory
{
    return [[self applicationDirectory] stringByAppendingPathComponent:[THUAccountManager defaultManager].currentAccount];
}

- (NSString *)accountDirectory:(NSString *)account
{
    return [[self applicationDirectory] stringByAppendingPathComponent:account];
}

- (void)saveData:(NSData *)fileData name:(NSString *)fileName course:(NSString *)course
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // Generate the file directory
    NSString *courseDir = [[self currentAccountDirectory] stringByAppendingPathComponent:course];
    
    if ([fileManager createDirectoryAtPath:courseDir withIntermediateDirectories:YES attributes:nil error:NULL] == NO) 
    {
        NSLog(@"THUFileManager: error creating directory %@.", courseDir);
    }
    
    // Use a txt file to store the binary data
    NSString *fileDir = [courseDir stringByAppendingPathComponent:fileName];
    
    // Convert the file path to the standard url
    NSURL *fileURL = [NSURL fileURLWithPath:fileDir];
    
    // Write the file data to the directory and check.
    [fileData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
    if (error != nil) 
    {
        NSLog(@"THUFileManager: error writing file %@ data to URL: %@. Error : %@", fileName, fileDir, error.userInfo);
    }
}



- (NSData *)loadDataForFileName:(NSString *)fileName course:(NSString *)course error:(NSError *__autoreleasing *)error
{
    // Generate the file directory url
    NSString *fileDir = [[self currentFolderDir] stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:fileDir];
    
    // Read the data safely
    NSError *readError = nil;
    NSData *fileData = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&readError];
    if (readError != nil || fileData == nil) 
    {
        *error = readError;
        NSLog(@"THUFileManager: error reading file %@ data. Error : %@", fileName, readError.localizedDescription);
        return nil;
    }
    
    return fileData;
}


- (NSString *)directoryForFile:(NSString *)fileFullName course:(NSString *)course
{
    NSString *courseDir = [[self currentAccountDirectory] stringByAppendingPathComponent:course];
    NSString *fileDir = [courseDir stringByAppendingPathComponent:fileFullName];
    return fileDir;
}

- (NSString *)extensionForFile:(NSString *)fileFullName course:(NSString *)course
{
    NSString *folderDir = [[self currentAccountDirectory] stringByAppendingPathComponent:course];
    NSError *error = nil;
    NSArray *fileNamesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderDir error:&error];
    if (error == nil) 
    {
        for (NSString *name in fileNamesArray) {
            if ([name hasPrefix:fileFullName] == YES) {
                return [name pathExtension];
            }
        }
    }
    return nil;
}

- (BOOL)fileExistsForName:(NSString *)fileName course:(NSString *)course
{
    NSString *courseDir = [[self currentAccountDirectory] stringByAppendingPathComponent:course];
    NSString *fileDir = [courseDir stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:fileDir];
}

- (BOOL)deleteFile:(NSString *)fileName course:(NSString *)course
{
    NSString *courseDir = [[self currentAccountDirectory] stringByAppendingPathComponent:course];
    NSString *fileDir = [courseDir stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:fileDir];
    
    NSError *deleteError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&deleteError];
    if (deleteError != nil) 
    {
        NSLog(@"THUFileManager: error deleting file %@. Error : %@", fileName, deleteError.userInfo);
        return NO;
    }
    
    return YES;
}

- (BOOL)deleteAllFolders
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self currentAccountDirectory] error:&error];
    if (error != nil) 
    {
        return NO;
    }
    return YES;
}

@end



@implementation THUFileManager (Folder)

- (NSArray *)allFolderNames
{
    NSString *userDir = [[self applicationDirectory] stringByAppendingPathComponent:[THUAccountManager defaultManager].currentAccount];
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:userDir error:nil];
}

- (NSString *)selectedFolderName
{
    return self.currentFolderName;
}

- (NSString *)selectedFolderDir
{
    return self.currentFolderDir;
}

- (void)newFolder:(NSString *)folderName
{
    NSString *folderDir = [[self currentAccountDirectory] stringByAppendingPathComponent:folderName];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:folderDir withIntermediateDirectories:YES attributes:nil error:&error] == NO) 
    {
        NSLog(@"THUFileManager: error creating folder at path: %@. Error : %@", folderDir, error.userInfo);
    }
}

- (void)switchToCurrentFolder:(NSString *)folderName
{
    if ([self folderDidExist:folderName] == NO) 
    {
        [self newFolder:folderName];
    }
    [self setCurrentFolderName:folderName];
    [self setCurrentFolderDir:[[self currentAccountDirectory] stringByAppendingPathComponent:folderName]];
}

- (BOOL)folderDidExist:(NSString *)folderName
{
    NSString *folderDir = [[self currentAccountDirectory] stringByAppendingPathComponent:folderName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderDir] == YES) 
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end


@implementation THUFileManager (File)

- (NSArray *)allFileDirs
{
    NSArray *allNames = [self allFileNames];
    NSMutableArray *allDirs = [[NSMutableArray alloc] initWithCapacity:allNames.count];
    for (int i = 0; i < allNames.count; i ++) 
    {
        [allDirs addObject:[self.currentFolderDir stringByAppendingPathComponent:[allNames objectAtIndex:i]]];
    }
    
    return allDirs;
}

- (NSArray *)allFileNames
{
    if (self.currentFolderDir == nil) 
    {
        NSLog(@"THUFileManager: the current folder must not be nil.");
        return nil;
    }
    
    NSError *error = nil;
    NSArray *allNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentFolderDir error:&error];
    if (error != nil) 
    {
        NSLog(@"THUFileManager: error getting all the file names in current dir. Error : %@", error.userInfo);
    }
    
    return allNames;
}

- (BOOL)setFile:(NSString *)fileName newExtension:(NSString *)extension
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *fileDir = [self.currentFolderDir stringByAppendingPathComponent:fileName];
    NSLog(@"old dir: %@", fileDir);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileDir] == YES) 
    {
        NSString *newFileName = [[fileName stringByDeletingPathExtension] stringByAppendingFormat:@".%@", extension];
        NSString *newFileDir = [[fileDir stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFileName];
        NSLog(@"new dir: %@", newFileDir);
        [fileManager moveItemAtPath:fileDir toPath:newFileDir error:&error];
        if (error != nil) 
        {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)fileExistsForName:(NSString *)fileName
{
    NSString *fileDir = [self.currentFolderDir stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:fileDir];
}

- (BOOL)deleteFile:(NSString *)fileName
{
    NSString *fileDir = [self.currentFolderDir stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:fileDir];
    NSError *deleteError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&deleteError];
    if (deleteError != nil) 
    {
        NSLog(@"THUFileManager: error deleting file %@. Error : %@", fileName, deleteError.userInfo);
        return NO;
    }
    
    return YES;
}

@end

