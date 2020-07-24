//
//  CzxAccountSettingsController.m
//  PortGo
//
//  Created by 今言网络 on 2017/11/10.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "CzxAccountSettingsController.h"
#import "Account.h"
#import "DataBaseManage.h"
#import "AppDelegate.h"
#import "HSLoginViewController.h"
#import "UIBarButtonItem+HSBackItem.h"
@interface CzxAccountSettingsController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
{
    
     Account *_mAccount;
    
    
    
    
}

@property (nonatomic)  UITableView * accountTableview;

@end



@implementation CzxAccountSettingsController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"账号信息";
  
    self.view.backgroundColor = [UIColor whiteColor];
    
    
       _mAccount = shareAppDelegate.portSIPHandle.mAccount;
  
    [self.view addSubview:self.accountTableview];
    
    // Do any additional setup after loading the view.
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 6;
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section==0) {
        
        return 2;
        
    }else {
        
           return 1;
    }
  
    
   
    
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"cell"];
    
    
    if (indexPath.section==0) {
        
        if (indexPath.row==0) {
            
            cell.textLabel.text = @"显示为";
        }
        else if (indexPath.row==1){
            
                 cell.textLabel.text = @"SIP服务器地址";
        }
        
        
    }else if(indexPath.section==1) {
        
                cell.textLabel.text = @"勿扰";
    }else if(indexPath.section==2) {
        
            cell.textLabel.text = @"拨号计划";
    }else if(indexPath.section==3) {
        
          cell.textLabel.text = @"呼叫转移";
    }else if(indexPath.section==4) {
        
          cell.textLabel.text = @"语音邮箱";
    }else if(indexPath.section==5) {
        
          cell.textLabel.text = @"退出登录";
    }
    
    
    
    return cell;
    
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==5) {
        
           [self logoutHandle:nil];
        
    }
    
    
    
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    
    view.backgroundColor = RGB(242, 242, 242);
    
    return view;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}


- (void)logoutHandle:(UIControlEvents*)event
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Sign Out", @"Sign Out") otherButtonTitles:nil];
    [actionSheet showInView:self.navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        if (_mAccount.presenceAgent == 1) {
            [portSIPEngine setPresenceStatus:-1 statusText:@"offline"];
        } else {
            //            NSMutableArray *arr = [contactView getSipContacts];
            
            NSMutableArray *arr = [contactView sipFriends];
            
            for (Contact *friend in arr) {
                NSLog(@"%ld",friend.subscribeID);
                [portSIPEngine setPresenceStatus:friend.subscribeID statusText:@"Available"];
            }
        }
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        HSLoginViewController *loginCtrl = [mainStoryBoard instantiateViewControllerWithIdentifier:@"HSLoginViewController"];
        [loginCtrl setAccount:portSIPEngine.mAccount];
        shareAppDelegate.window.rootViewController = loginCtrl;
        [shareAppDelegate releaseResource];
    }
}



-(UITableView*)accountTableview{
    
    
    if (!_accountTableview) {

        
       _accountTableview = [[UITableView alloc]initWithFrame:CGRectMake(0,0,ScreenWid,ScreenHeight) style:0];

        
       // [accountTableview zy_registClassCell:[yanchangshiyongCell class]];
        
        
        _accountTableview.backgroundColor = [UIColor clearColor];
        //    _myTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.0001)];
        // _myTable.separatorStyle =0;
        //myTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        _accountTableview.delegate = self;
        _accountTableview.dataSource = self;
        
        
        _accountTableview.scrollEnabled = YES;
        
        _accountTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_accountTableview flashScrollIndicators];
        
    }
    return _accountTableview;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
