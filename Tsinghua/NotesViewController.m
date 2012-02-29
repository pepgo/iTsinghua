//
//  NotesViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NotesViewController.h"
#import "NoteListViewController.h"
#import "TFHpple.h"

@interface NotesViewController (Private)

- (void)getNotesCount;

@end

@implementation NotesViewController

#pragma mark - View lifecycle
//[getNewInfo] method will not be invoke in this version
- (void)getNewInfo {
    [self.mainTableView reloadData];
    int old = 0;
    int new = 0;
    int value;
    
    //get old count
    for (int i = 0; i < courseNameArray.count; i++) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"Note-%@",[courseNameArray objectAtIndex:i]]]) {
            value = [[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"Note-%@",[courseNameArray objectAtIndex:i]]] intValue];
            old = old + value;
        } else {
            old = 0;
        }
        NSLog(@"%d",[[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"Note-%@",[courseNameArray objectAtIndex:i]]] intValue]);
        NSLog(@"%@",[NSString stringWithFormat:@"Note-%@",[courseNameArray objectAtIndex:i]]);
        NSLog(@"value:%d",value);
    }
    
    //get new count
    if ([CourseInfo sharedCourseInfo].notesCount.count > 0) {
        for (int i = 0; i < courseNameArray.count; i++) {
            value = [(NSNumber *)[[CourseInfo sharedCourseInfo].notesCount objectAtIndex:i] intValue];
            new = new + value;
            NSLog(@"value:%d",value);
        }
    } else {
        return;
    }
    
    NSLog(@"old:%d",old);
    NSLog(@"new:%d",new);
    
    if ((new - old) > 0) {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"New"];
    }
}

- (void)viewDidLoad
{
    // Add the refresh button
    self.navigationItem.leftBarButtonItem = self.refreshButton;
    
    // Load the data source
    [self reloadDataSource];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.mainTableView setDataSource:self];
    [self.mainTableView setDelegate:self];
    [self getNewInfo];
}

- (void)reloadDataSource
{
    // No other content but the downloaded course names will be shown in this view.
    self.courseNameArray = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].courseName];
    [self.mainTableView reloadData];
}

- (void)requestDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqual:thuRequestFinishNotification]) {
        [self reloadDataSource];
    }
    [super requestDidFinish:notification];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    cell.textLabel.text = [self.courseNameArray objectAtIndex:indexPath.row];
//    cell.detailTextLabel.text = @"hello";
    
    /*if ([CourseInfo sharedCourseInfo].notesCount.count != 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"公告数目: %@", [[CourseInfo sharedCourseInfo].notesCount objectAtIndex:indexPath.row]];
    } else {
        cell.detailTextLabel.text = @"正在更新数据...";
    }*/
    
    return cell;
}

/*- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    cell.textLabel.text = [self.courseNameArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"hello";
   if (self.noteCounterArray.count != 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"公告数目: %@", [self.noteCounterArray objectAtIndex:indexPath.row]];

    }
}*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do not forget to clear up all the previous note data
    [[[CourseInfo sharedCourseInfo] noteBasicInfo] removeAllObjects];
    
    // Push to the note list view for the selected course
    NoteListViewController *noteListViewController = [[NoteListViewController alloc] initWithCellStyle:UITableViewCellStyleSubtitle 
                                                                                                 index:indexPath.row];
    [self.navigationController pushViewController:noteListViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
