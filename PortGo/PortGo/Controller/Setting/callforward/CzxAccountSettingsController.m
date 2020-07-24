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

#import "DialPlanViewController.h"
#import "CallForwardingViewController.h"
#import "IQKeyboardManager.h"
#import "Toast+UIView.h"
#import "MyQRViewController.h"
#import "WSLNativeScanTool.h"
#import "UIColor_Hex.h"
#import "HttpHelper.h"

@interface CzxAccountSettingsController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate>
{
    
     Account *_mAccount;
    
   UILabel * displaynamelabel;
    
    UILabel *SIPlabel;
    
    
    UISwitch * DoNotDisturbSwitch;
    
    
    
    UITextField * VoiceMailTextfield;
    
    
    
}

@property (nonatomic)  UITableView * accountTableview;

@end



@implementation CzxAccountSettingsController

-(void)viewWillAppear:(BOOL)animated
{
    
    [IQKeyboardManager sharedManager].enable = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewwilldisapper");
    
       _mAccount.voiceMail =VoiceMailTextfield.text;
    
    [IQKeyboardManager sharedManager].enable = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Account",@"Account");
  
    self.view.backgroundColor = RGB(242, 242, 242);

    _mAccount = shareAppDelegate.portSIPHandle.mAccount;
    
    NSLog(@"_mAccount.userName==个人中心===%@",_mAccount.userName);
  
  
    [self.view addSubview:self.accountTableview];
    
    
    //自动滑到设置呼叫转移
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showCallforward) name:@"showCallforward" object:nil];
    
    
    
    
    // Do any additional setup after loading the view.
}

-(void)showCallforward{
    
    
    NSIndexPath *indexpath  = [NSIndexPath indexPathForRow:4 inSection:0];
    
    
    // [self.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    [self tableView:self.accountTableview didSelectRowAtIndexPath:indexpath];
    
    
}



#pragma mark --
#pragma mark tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    

   
      return 6;
    

  
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section==0) {
        
        return 3;
        
    }else {
        
           return 1;
    }
  
    
   
    
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * celld = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:celld];
    
      cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    
    if (indexPath.section==0) {
        
        if (indexPath.row==0) {
            
            cell.textLabel.text =   NSLocalizedString(@"Display as",@"Display as");
            
            displaynamelabel = [[UILabel alloc]init];
            
            displaynamelabel.frame = CGRectMake(ScreenWid-150, 0, 140, 44);
            
            displaynamelabel.textAlignment = NSTextAlignmentRight;
            
            displaynamelabel.font = [UIFont systemFontOfSize:13];
            
            displaynamelabel.text = _mAccount.userName;
            
            if (_mAccount.displayName && ![_mAccount.displayName isEqualToString:@""]) {
                
                displaynamelabel.text =_mAccount.displayName;
                
            }
            
//            #if !defined(PORTGO)
//
//            NSString * tempstr = [[NSUserDefaults standardUserDefaults]objectForKey:_mAccount.userName];
//
//               displaynamelabel.text = tempstr;
//
//        #endif
            
            
            
            
            [cell.contentView addSubview:displaynamelabel];
            
            
        }
        else if (indexPath.row==1){
            
            cell.textLabel.text = NSLocalizedString(@"SIP Server",@"SIP Server");
            
            SIPlabel = [[UILabel alloc]init];
            
            SIPlabel.frame = CGRectMake(ScreenWid-170, 0, 160, 44);
            
            SIPlabel.textAlignment = NSTextAlignmentRight;
            
            SIPlabel.font = [UIFont systemFontOfSize:13];
            
            SIPlabel.text = [NSString stringWithFormat:@"%@@%@",_mAccount.userName,_mAccount.SIPServer];
            
            if (_mAccount.SIPServerPort &&  _mAccount.SIPServerPort  !=5060) {
                
                SIPlabel.text= [NSString stringWithFormat:@"%@@%@:%d",_mAccount.userName,_mAccount.SIPServer,_mAccount.SIPServerPort];
            }
         
            
       //     if ([_mAccount.userDomain isEqualToString:@""] ||  [_mAccount.userDomain isEqual:[NSNull null]]) {
                
         
//                   SIPlabel.text = [NSString stringWithFormat:@"%@@%@",_mAccount.userName,_mAccount.SIPServer];
//
//                if (_mAccount.SIPServerPort &&  _mAccount.SIPServerPort  !=5060) {
//
//                    SIPlabel.text= [NSString stringWithFormat:@"%@@%@:%d",_mAccount.userName,_mAccount.SIPServer,_mAccount.SIPServerPort];
//                }
            
//            }
//            else
//            {
//                  SIPlabel.text = [NSString stringWithFormat:@"%@@%@",_mAccount.userName,_mAccount.userDomain];
//            }
            
            
            if (![_mAccount.userDomain isEqualToString:@""] ){
                
                    SIPlabel.text = _mAccount.userDomain;
                
 
            }
            else
            {
                     SIPlabel.text = _mAccount.SIPServer;
                
                
                if (_mAccount.SIPServerPort &&  _mAccount.SIPServerPort  !=5060) {
                    
                    SIPlabel.text= [NSString stringWithFormat:@"%@:%d",_mAccount.SIPServer,_mAccount.SIPServerPort];
                }
                
            }
            
            
            
            [cell.contentView addSubview:SIPlabel];
            
        }
        else if (indexPath.row==2){
            
            
            cell.textLabel.text = NSLocalizedString(@"Outbound",@"Outbound");
            
            SIPlabel = [[UILabel alloc]init];
            
            SIPlabel.frame = CGRectMake(ScreenWid-170, 0, 160, 44);
            
            SIPlabel.textAlignment = NSTextAlignmentRight;
            
            SIPlabel.font = [UIFont systemFontOfSize:13];
            
        
            
            if (![_mAccount.userDomain isEqualToString:@""] ){
                
                
                SIPlabel.text = _mAccount.SIPServer;
                
                
                
                if (_mAccount.SIPServerPort &&  _mAccount.SIPServerPort  !=5060) {
                    
                    SIPlabel.text= [NSString stringWithFormat:@"%@:%d",_mAccount.SIPServer,_mAccount.SIPServerPort];
                }
            }
            
            
            
            [cell.contentView addSubview:SIPlabel];
            
        }
        
//        else if (indexPath.row==3){
//
//
//            cell.textLabel.text = NSLocalizedString(@"MyQR",@"MyQR");
//
//            SIPlabel = [[UILabel alloc]init];
//
//            SIPlabel.frame = CGRectMake(ScreenWid-170, 0, 160, 44);
//
//            SIPlabel.textAlignment = NSTextAlignmentRight;
//
//            SIPlabel.font = [UIFont systemFontOfSize:13];
//
//
//            [cell.contentView addSubview:SIPlabel];
//
//                 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
        
        
    }else if(indexPath.section==1) {
        
        cell.textLabel.text = NSLocalizedString(@"Do Not Disturb",@"Do Not Disturb");
        
        
        DoNotDisturbSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWid-60, 8, 50, 28)];
     
        DoNotDisturbSwitch.onTintColor = [UIColor colorWithRed:29.0/255 green:172.0/255 blue:239.0/255 alpha:1];
        
        [DoNotDisturbSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
     
        BOOL setDoNotDisturb = [[NSUserDefaults standardUserDefaults]boolForKey:@"setDoNotDisturb"];
        
        DoNotDisturbSwitch.on =setDoNotDisturb;
        
        
        
        [cell.contentView addSubview:DoNotDisturbSwitch];
        
        
    }else if(indexPath.section==2) {
        
            cell.textLabel.text = NSLocalizedString(@"Dial Plan",@"Dial Plan");
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(indexPath.section==3) {
        
          cell.textLabel.text = NSLocalizedString(@"Call Forward",@"Call Forward");
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(indexPath.section==4) {
        
          cell.textLabel.text =  NSLocalizedString(@"Voice Mail",@"Voice Mail");
        
        VoiceMailTextfield = [[UITextField alloc]init];
        
        VoiceMailTextfield.frame = CGRectMake(ScreenWid-150, 0, 140, 44);
        
        VoiceMailTextfield.delegate =self;
        
        VoiceMailTextfield.textAlignment = NSTextAlignmentRight;
        
        VoiceMailTextfield.font = [UIFont systemFontOfSize:13];
        
        // NSString * VoiceMail = [[NSUserDefaults standardUserDefaults]objectForKey:@"VoiceMail"];
        
        VoiceMailTextfield .text = _mAccount.voiceMail;
        
        VoiceMailTextfield.placeholder =NSLocalizedString(@"Voice Mail",@"Voice Mail");
        
        [cell.contentView addSubview:VoiceMailTextfield];
        
    }else if(indexPath.section==5) {
        
        UILabel *logout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,ScreenWid, 44)];
        logout.text = NSLocalizedString(@"Sign Out", @"Sign Out");
        logout.textAlignment = NSTextAlignmentCenter;
        logout.textColor = [UIColor redColor];
        [cell.contentView addSubview:logout];
        cell.userInteractionEnabled = YES;
        
      
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        
//        if (indexPath.row ==3) {
//
//            __weak typeof(self) weakSelf = self;
//
//            NSString* mystr = [NSString stringWithFormat:@"%@@%@",_mAccount.userName,_mAccount.SIPServer];
//
//
//            BOOL   usericondataBOOL = [[NSUserDefaults standardUserDefaults]boolForKey:@"usericondataBOOL"];
//
//            UIImage * tempimage = [[UIImage alloc]init];
//
//
//            if (usericondataBOOL) {
//
//                _mAccount.usericondata = [[NSUserDefaults standardUserDefaults]objectForKey:@"usericondata"];
//
//                tempimage  = [UIImage imageWithData:_mAccount.usericondata];
//
//            }
//            else
//            {
//                _mAccount.usericondata = nil;
//
//                tempimage = [UIImage imageNamed:@"about_logo"];
//
//            }
//
//            MyQRViewController * myQRcon  = [[MyQRViewController alloc]init];
//
//
//
//            NSLog(@"mystr===%@",mystr);
//
//
//
//            myQRcon.qrImage =  [WSLNativeScanTool createQRCodeImageWithString:mystr andSize:CGSizeMake(250, 250) andBackColor:[UIColor whiteColor] andFrontColor:SYSTEM_COLOR andCenterImage:tempimage];
//
//            myQRcon.qrString = mystr;
//
//            myQRcon.titlestr = NSLocalizedString(@"MyQR", @"MyQR");
//
//            myQRcon.pushBool = YES;
//
//           self.hidesBottomBarWhenPushed = YES;
//            [weakSelf.navigationController pushViewController:myQRcon animated:YES];
//
//
//
//        }
        
    
    }
    
    if (indexPath.section==2) {
        
        DialPlanViewController *DialPlancon  = [[DialPlanViewController alloc]init];
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:DialPlancon animated:YES];
        
    }
    
    if (indexPath.section==3) {
        
        CallForwardingViewController *callforwardingcon  = [[CallForwardingViewController alloc]init];
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:callforwardingcon animated:YES];
        
    }
    
    
    if (indexPath.section==4) {
        
        [VoiceMailTextfield becomeFirstResponder];
        
    }
    
    
    if (indexPath.section==5) {
        [httpHelper cancelAll];
        [databaseManage updateAllProcessingStatus2Fail];
        
        [self logoutHandle:nil];
    }
    
    
    
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    
    view.backgroundColor = RGB(242, 242, 242);
    
    return view;
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    
    
#if defined(PHONESPEAK)
    
    if (section==2 ||  section==3 || section==4) {
        
        return 0;
    }
    
     return 30;
    
    
#else
    
    
   return 30;
    
#endif
    
    
        return 30;
    
}





- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
        #if defined(PHONESPEAK)
    
    if (indexPath.section==2 ||  indexPath.section==3 || indexPath.section==4) {
        
                return 0;
    }
    
        return 44.0f;

    
            #else
    
    
                return 44.0f;
    
        #endif
    
    
  //  return 44.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //分割线补全
    
    if (indexPath.section==5) {
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    

}

#pragma mark --
#pragma mark  // 勿扰模式 开关事件切换通知

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        NSLog(@"开");
        [portSIPEngine setDoNotDisturb:YES];
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"setDoNotDisturb"];
        
        [self.view makeToast:NSLocalizedString(@"Disturb Message", @"Disturb Message") duration:2.0 position:@"center"];
        
    }else {
        NSLog(@"关");
        
           [portSIPEngine setDoNotDisturb:NO];
        
           [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"setDoNotDisturb"];
    }
}

#pragma mark --
#pragma mark   UiTextfield delegate

- ( BOOL )textFieldShouldReturn:( UITextField*)textField{
    
    NSLog(@"VoiceMailTextfield.text==%@",textField.text);
    
  //  [[NSUserDefaults standardUserDefaults]setObject:VoiceMailTextfield.text forKey:@"VoiceMail"];
    
    _mAccount.voiceMail =VoiceMailTextfield.text;
    
    
    [databaseManage saveActiveAccount:_mAccount reset:NO];
    
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)logoutHandle:(UIControlEvents*)event
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Sign Out", @"Sign Out") otherButtonTitles:nil];
    [actionSheet showInView:self.navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        
        if ([shareAppDelegate.callManager getConnectCallNum]){
       
            
            [self.view makeToast:NSLocalizedString(@"Unable to logout", @"Unable to logout") duration:1.0 position:@"center"];
            
            
            return;
            
            
        }
        
        
        
        if (_mAccount.presenceAgent == 1) {
            [portSIPEngine setPresenceStatus:-1 statusText:@"offline"];
        } else {
            //            NSMutableArray *arr = [contactView getSipContacts];
            
            NSMutableArray *arr = [contactView contacts];
            
            for (Contact *friend in arr) {
                NSLog(@"%ld",friend.subscribeID);
                [portSIPEngine setPresenceStatus:friend.subscribeID statusText:@"offline"];
            }
        }
        
        
      //  [messageVIew loginoutEmptyHistory];
        

        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"AutoLogin"];
        
        
        
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        HSLoginViewController *loginCtrl = [mainStoryBoard instantiateViewControllerWithIdentifier:@"HSLoginViewController"];
        [loginCtrl setAccount:portSIPEngine.mAccount];
        
        NSLog(@"portSIPEngine.mAccount.hasOutProxyServer===%d",portSIPEngine.mAccount.hasOutProxyServer);
        
        
        shareAppDelegate.window.rootViewController = loginCtrl;
        [shareAppDelegate releaseResource];
        
           //[[AppDelegate sharedInstance]addPushSupportWithPortPBX:NO];
        
    
        
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
