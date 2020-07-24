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

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    self.view.backgroundColor = bkColor;
    [self.navigationController.navigationBar setBarTintColor:bkColor];
    [self.tabBarController.tabBar setBarTintColor:bkColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Account",@"Account");
    
    _mAccount = shareAppDelegate.portSIPHandle.mAccount;
    
    [self.view addSubview:self.accountTableview];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showCallforward) name:@"showCallforward" object:nil];
    
    
    
    [self traitCollectionDidChange:self.traitCollection];
    
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
        
        return 4;
        
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
            
            if (![_mAccount.userDomain isEqualToString:@""] ){
                if(([_mAccount.SIPServer isEqualToString:@"(null)"]||[[_mAccount.SIPServer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0)&&(_mAccount.SIPServerPort &&  _mAccount.SIPServerPort  !=5060)){
                    SIPlabel.text= [NSString stringWithFormat:@"%@:%d",_mAccount.userDomain,_mAccount.SIPServerPort];
                }else{
                    SIPlabel.text = _mAccount.userDomain;
                }
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
                if ([_mAccount.SIPServer isEqualToString:@"(null)"]||[[_mAccount.SIPServer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0){
                    SIPlabel.text= nil;
                }else{
                    if (_mAccount.SIPServerPort  !=5060) {
                        
                        SIPlabel.text= [NSString stringWithFormat:@"%@:%d",_mAccount.SIPServer,_mAccount.SIPServerPort];
                    }else{
                        SIPlabel.text= _mAccount.SIPServer;
                    }
                }
            }
            
            
            
            [cell.contentView addSubview:SIPlabel];
            
        }else if (indexPath.row==3){
            cell.textLabel.text = NSLocalizedString(@"Transport", @"Transport");
            SIPlabel = [[UILabel alloc]init];
            SIPlabel.frame = CGRectMake(ScreenWid-170, 0, 160, 44);
            SIPlabel.textAlignment = NSTextAlignmentRight;
            SIPlabel.font = [UIFont systemFontOfSize:13];
            //NSArray* _transportProtocol = @[@"UDP",@"TLS",@"TCP",@"PERS_UDP",@"PERS_TCP"];
            SIPlabel.text= _mAccount.transportType;
            
            [cell.contentView addSubview:SIPlabel];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
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
        
        VoiceMailTextfield.text = _mAccount.voiceMail;
        
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
        
        [self logoutHandle:nil];
        
    }
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    view.backgroundColor = bkColor;
    
    return view;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
#pragma mark

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        [portSIPEngine setDoNotDisturb:YES];
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"setDoNotDisturb"];
        
        [self.view makeToast:NSLocalizedString(@"Disturb Message", @"Disturb Message") duration:2.0 position:@"center"];
        
    }else {
        [portSIPEngine setDoNotDisturb:NO];
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"setDoNotDisturb"];
    }
}

#pragma mark --
#pragma mark   UiTextfield delegate

- ( BOOL )textFieldShouldReturn:( UITextField*)textField{
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
        
        [shareAppDelegate.callManager clear];
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
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"AutoLogin"];
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        HSLoginViewController *loginCtrl = [mainStoryBoard instantiateViewControllerWithIdentifier:@"HSLoginViewController"];
        [loginCtrl setAccount:portSIPEngine.mAccount];
        
        
        shareAppDelegate.window.rootViewController = loginCtrl;
        [shareAppDelegate releaseResource];
        
    }
}



-(UITableView*)accountTableview{
    
    
    if (!_accountTableview) {
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGRect rectNav = self.navigationController.navigationBar.frame;
        _accountTableview = [[UITableView alloc]initWithFrame:CGRectMake(0,0,ScreenWid,ScreenHeight-rectStatus.size.height-rectNav.size.height) style:0];
        _accountTableview.backgroundColor = [UIColor clearColor];
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


@end
