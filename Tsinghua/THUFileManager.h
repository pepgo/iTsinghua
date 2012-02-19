//
//  THUFileManager.h
//  Tsinghua
//
//  Created by Xin Chen on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THUAccountManager.h"

@interface THUFileManager : NSObject
{
    NSString *_currentFolderName;
    NSString *_currentFolderDir;
}

// Return the shared instance of THUFileManager
// @since 2.1
+ (THUFileManager *)defaultManager;

// @since 2.1
- (void)saveData:(NSData *)fileData name:(NSString *)fileFullName course:(NSString *)course;

// @since 2.1
- (NSData *)loadDataForFileName:(NSString *)fileFullName course:(NSString *)course error:(NSError **)error;

// Return the file full directory given the full name and course name
// @since 2.2
- (NSString *)directoryForFile:(NSString *)fileFullName course:(NSString *)course;

// Return the file type given the file name and course name.
// @since 2.2
- (NSString *)fileTypeForName:(NSString *)fileName course:(NSString *)course;

// Search the specific file given the file full name. If the file exists, view controller can load the data directly.
// @since 2.1
- (BOOL)fileExistsForName:(NSString *)fileFullName course:(NSString *)course;

// Delete the downloaded files given the file name and course name
// @since 2.1
- (BOOL)deleteFile:(NSString *)fileName course:(NSString *)course;

// Delete all the folders and files inside. This is not reversible. Be cautious!
// @since 2.1
- (BOOL)deleteAllFolders;

@end


/******************************************************
 
 These APIs need user set current account first
 
 *****************************************************/

@interface THUFileManager (Folder) 

// Return the current selected folder name or full directory
// @since 2.1
- (NSString *)selectedFolderName;
- (NSString *)selectedFolderDir;

// Create a new folder given the folder name for current account
// @since 2.2
- (void)newFolder:(NSString *)folderName;

// Switch the current folder to the folder given the folder name for current account
// @since 2.1
- (void)switchToCurrentFolder:(NSString *)folderName;

// Return whether the given folder exists for current account.
// @since 2.1
- (BOOL)folderDidExist:(NSString *)folderName;

// Return all the folder names for current account
// @since 2.1
- (NSArray *)allFolderNames;

@end


@interface THUFileManager (File) 

// Return the file names or file full path in current folder. The file name contains their extensions.
// @since 2.1
- (NSArray *)allFileNames;
- (NSArray *)allFileDirs;

// Search the specific file in current folder for current account.
// @since 2.1
- (BOOL)fileExistsForName:(NSString *)fileName;

// Set the given file new extension in current folder for current account
// @since 2.1
- (BOOL)setFile:(NSString *)fileName newExtension:(NSString *)extension;

// Delete the downloaded files given the file name
// @since 2.1
- (BOOL)deleteFile:(NSString *)fileName;

@end
