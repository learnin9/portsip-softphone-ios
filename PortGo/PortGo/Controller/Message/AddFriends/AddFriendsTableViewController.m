//
//  AddFriendsTableViewController.m
//  PortSIP
//
//  Created by 今言网络 on 2017/12/14.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "AddFriendsTableViewController.h"
#import "addFriendCell.h"
#import "AddorEditViewController.h"

#import "JRDB.h"
#import "addFriendModel.h"

#import "Options.h"
#import "DataBaseManage.h"
#import "AppDelegate.h"
@interface AddFriendsTableViewController ()

{
    NSMutableArray * hisArr;
}

@end

@implementation AddFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =NSLocalizedString(@"New Friends", @"New Friends");
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self gethis];
}


-(void)gethis{
    
    hisArr = [[NSMutableArray alloc]initWithArray:[addFriendModel jr_getAll]];
    hisArr = [[NSMutableArray alloc]initWithArray:[[hisArr reverseObjectEnumerator] allObjects]];
    
    NSLog(@"his==========%@",hisArr);
    [self.tableView reloadData];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.AddFriendsArr.count + hisArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if (indexPath.row <  self.AddFriendsArr.count) {
        
        addFriendCell *cell  = [[addFriendCell alloc]init];
        [cell initcell];
        
        History *his = [self.AddFriendsArr objectAtIndex:indexPath.row];

        [cell setcell:his andtag:indexPath.row+258];
        
        cell.myDeclineBlock = ^(NSInteger tag) {
        Options *options = [databaseManage mOptions];
        options.mMsgBadge -=1;
        
        if (options.mMsgBadge <0) {
            options.mMsgBadge = 0;
        }
        
        [databaseManage saveOptions];
        [shareAppDelegate refreshItemBadge];
    //    NSLog(@"Decline tag=%d",tag);
        
            History *his = [self.AddFriendsArr objectAtIndex:tag];
        addFriendModel * model = [[addFriendModel alloc]init];
        model.mRemoteParty = his.mRemoteParty;
        model.isedit = NO;

        [model jr_saveOrUpdate];

        [self.AddFriendsArr removeObjectAtIndex:tag];
        
        self->hisArr = [[NSMutableArray alloc]initWithArray:[addFriendModel jr_getAll]];
        self->hisArr = [[NSMutableArray alloc]initWithArray:[[self->hisArr reverseObjectEnumerator] allObjects]];
        
        [self.tableView reloadData];
 };
    
    cell.myAcceptBlock =  ^(NSInteger tag) {
        
        Options *options = [databaseManage mOptions];
        options.mMsgBadge -=1;
        
        if (options.mMsgBadge <0) {
            options.mMsgBadge = 0;
        }
        
        [databaseManage saveOptions];
        
        [shareAppDelegate refreshItemBadge];
        
        History *his = [self.AddFriendsArr objectAtIndex:tag];
        NSString *tempstr ;
        
        if ([his.mRemoteParty rangeOfString:@"@"].location == NSNotFound) {
            tempstr  = his.mRemoteParty;
        }else{
            NSArray *strs = [his.mRemoteParty componentsSeparatedByString:@"@"];
            NSString *first = strs[0];
            tempstr  = first;
        }

        addFriendModel * model = [[addFriendModel alloc]init];
        model.mRemoteParty = his.mRemoteParty;
        model.isedit = YES;
        [model jr_saveOrUpdate];
        
        
        [self.AddFriendsArr removeObjectAtIndex:tag];
        
        self->hisArr = [[NSMutableArray alloc] initWithArray:[addFriendModel jr_getAll]];
        self->hisArr = [[NSMutableArray alloc] initWithArray: [[self->hisArr reverseObjectEnumerator] allObjects]];
        [self.tableView reloadData];
        
        AddorEditViewController *ctr = [[AddorEditViewController alloc] init];
        ctr.modalPresentationStyle = UIModalPresentationFullScreen;
        ctr.recognizeID = 2689;
    
        ctr.numbPadenterString =his.mRemoteParty;
        
        ctr.addfriendname = tempstr;
        
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:ctr];
        navc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navc animated:YES completion:nil];
        
    };
    
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
        
    }
    else
    {
        
        addFriendCell *cell  = [[addFriendCell alloc]init];
        
        [cell initHisCell];
        
        
        addFriendModel *his = [hisArr objectAtIndex:indexPath.row - self.AddFriendsArr.count];
        
        
        [cell setHisCell:his];
        
        return cell;
        
    }
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

//删除历史好友请求


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath

{
    return   UITableViewCellEditingStyleDelete;
}

//先要设Cell可编辑

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.row <  self.AddFriendsArr.count) {
         return NO;
    }else
    {
        return YES;
    }
    
    return YES;
}

//进入编辑模式，按下出现的编辑按钮后

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    [tableView setEditing:NO animated:YES];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSLog(@"firend delete");
        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定删除该消息？" preferredStyle:UIAlertControllerStyleAlert];
//
//        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//
//        }]];
            //[self presentViewController:alertController animated:YES completion:nil];

        [self deletelist:indexPath];
        
    }
}

//修改编辑按钮文字

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath

{
    return NSLocalizedString(@"Delete", @"Delete");
}

//设置进入编辑状态时，Cell不会缩进

- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)deletelist:(NSIndexPath*)indexpath{

    addFriendModel *his = [hisArr objectAtIndex:indexpath.row - self.AddFriendsArr.count];
    [his jr_delete];
//        [self.tableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
//
    [self gethis];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
