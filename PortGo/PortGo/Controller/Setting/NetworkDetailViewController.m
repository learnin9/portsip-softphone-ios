//
//  NetworkDetailViewController.m
//  telephony
//
//  Created by Joe Lepple on 4/19/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "NetworkDetailViewController.h"
#import "NetworkTranportViewController.h"
#import "DataBaseManage.h"
#import "HSPreferencesDetailViewController.h"
#import "UIBarButtonItem+HSBackItem.h"

#import "AppDelegate.h"

#import "AllRecordingFilesViewController.h"


#define kTranportKey    NSLocalizedString(@"Network connection", @"Network connection")
#define kSrtp       NSLocalizedString(@"SRTP", @"SRTP")
#define kServerKey      NSLocalizedString(@"STUN Server", @"STUN Server")

#define kTextFieldWidth  175.0f
#define kTextFieldHeight 25.0f
#define kLeftMargin      105.0f
#define kRightMargin     5.0f

@interface NetworkDetailViewController()<UITextFieldDelegate, HSPreferencesDetailViewControllerDelegate>
{
    NSArray *_preferencesArray;
    NSDictionary *_preferencesDetailDict;
    
    UIView *_rtpPortView;
    UITextField *_rtpFromTextField;
    
    UIView *_forwardView;
    UITextField *_forwardTextField;
    
    NSArray *_mResolutionArray;
    
    UISwitch *Enable_PRACK;
    
    UISwitch * Enable_Early_Media;
    
    
    
    UISwitch *Enable_IMS;
    UISwitch *Passive_Session_Timer;
    
    UISwitch *Enalbe_Call_Record;
    
    
}

@end

@implementation NetworkDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Preferences", @"Preferences");
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PreferencesEnglish" ofType:@"plist"];
    _preferencesArray = [NSArray arrayWithContentsOfFile:path];
    
    NSString *pathDetail = [[NSBundle mainBundle] pathForResource:@"PreferencesDetailEnglish" ofType:@"plist"];
    _preferencesDetailDict = [NSDictionary dictionaryWithContentsOfFile:pathDetail];
    
    _rtpPortView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    _rtpFromTextField = [[UITextField alloc] initWithFrame:_rtpPortView.frame];
    [_rtpFromTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_rtpFromTextField setFont:[UIFont systemFontOfSize:14.0f]];
    _rtpFromTextField.textAlignment = NSTextAlignmentRight;
    _rtpFromTextField.delegate = self;
    _rtpFromTextField.tag = 1100;
    _rtpFromTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_rtpPortView addSubview:_rtpFromTextField];
    
    _rtpFromTextField.text = [NSString stringWithFormat:@"%d", databaseManage.mOptions.rtpPortFrom];
    
    _forwardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    _forwardTextField = [[UITextField alloc] initWithFrame:_forwardView.frame];
    _forwardTextField.delegate = self;
    _forwardTextField.tag = 1401;
    _forwardTextField.text = databaseManage.mOptions.forwardTo;
    _forwardTextField.placeholder = @"SIP:someone@example.com";
    [_forwardView addSubview:_forwardTextField];
    
    _mResolutionArray = [[NSArray alloc]initWithObjects:@"QCIF  <176*144>", @"CIF    <352*288>", @"720P <1280*720>", nil];
    
    //  self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(onBack:)];
}

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    [super viewWillAppear:YES];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [databaseManage saveOptions];
    [super viewDidDisappear:animated];
}

#pragma mark - TableView DataSource Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==2 && ![databaseManage.mOptions supportCallKit]){
        return 0;
    }
    
    return 44.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _preferencesArray.count - 1 +2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifndef HAVE_VIDEO
    if (section == 4) {
        return 0;
    }
    
    
#endif
    if (section==7) {
        return 4;
    }
    
    if (section==8) {
        
        return 2;
    }
    
    
    
    return [_preferencesArray[section + 1] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *cellIdentifer = @"CellIdentifer";
    
    
    NSString * cellIdentifer = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifer];
    }
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = nil;
    cell.textLabel.text = nil;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    if (!(section == 7 || section == 8)) {
        cell.textLabel.text = NSLocalizedString(_preferencesArray[section + 1][row], _preferencesArray[section + 1][row]);
    }
    
    UISwitch *switchOperation = [[UISwitch alloc]init];
    [switchOperation addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
    switchOperation.onTintColor = [UIColor colorWithRed:29.0 / 255 green:172.0 / 255 blue:239.0 / 255 alpha:1];
    
    if (section == 0) {
        switchOperation.on = (databaseManage.mOptions.use3G != 0);
        switchOperation.tag = 1000 + row;
        cell.accessoryView = switchOperation;
    }
    else if (section == 1) {
        switchOperation.on = (databaseManage.mOptions.forceBackground != 0);
        switchOperation.tag = 1100 + row;
        cell.accessoryView = switchOperation;
    }
    
    else if (section == 2) {
        
        switchOperation.on = (databaseManage.mOptions.enableCallKit != 0) ;
        switchOperation.userInteractionEnabled = YES;
        switchOperation.tag = 1200 + row;
        cell.accessoryView = switchOperation;
        if([databaseManage.mOptions supportCallKit]){
            cell.hidden = NO;
        }else{
            switchOperation.userInteractionEnabled = NO;
            cell.hidden = YES;
        }
        
    }
    else if(section == 3){
        if (row == 0) {
            cell.accessoryView = _rtpPortView;
        }
        else{
            switchOperation.tag = 1300+row;
            cell.accessoryView = switchOperation;
        }
    }
    else if (section == 4) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (row == 0) {
            NSArray *array = [[NSArray alloc]initWithObjects:@"QCIF", @"CIF", @"720P", nil];
            if (databaseManage.mOptions.videoResolution < array.count) {
                cell.detailTextLabel.text = [array objectAtIndex:databaseManage.mOptions.videoResolution];
            }
        }
        else if (row == 1) {
            cell.detailTextLabel.text = [[NSString alloc]  initWithFormat:@"%d fps",databaseManage.mOptions.videoFrameRate];
        }
        else if (row == 2) {
            cell.detailTextLabel.text = [[NSString alloc]  initWithFormat:@"%d Kbps",databaseManage.mOptions.videoBandwidth];
        }
        else if (row == 3) {//Nack
            cell.accessoryType = UITableViewCellAccessoryNone;
            switchOperation.tag = 1400+row;
            cell.accessoryView = switchOperation;
            switchOperation.on = databaseManage.mOptions.videoNACK;
        }
    }
    else if (section == 5) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString *str = _preferencesDetailDict[_preferencesArray[0][section]][databaseManage.mOptions.useSRTP];
        cell.detailTextLabel.text = NSLocalizedString(str, str);
    }
    else if (section == 6) {
        if (row == 1) {
            switchOperation.on = databaseManage.mOptions.playDtmfTone;
            switchOperation.tag = 1600+row;
            cell.accessoryView = switchOperation;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSString *str = _preferencesDetailDict[_preferencesArray[0][section]][databaseManage.mOptions.dtmfOfInfo];
            cell.detailTextLabel.text = str;
        }
    }
    else if (section==7 ){
        
        
        if  (indexPath.row==0){
            
            cell.textLabel.text = NSLocalizedString(@"Enable PRACK",@"Enable PRACK");
            
            
            Enable_PRACK = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWid-60, 8, 50, 28)];
            
            Enable_PRACK.onTintColor = [UIColor colorWithRed:29.0 / 255 green:172.0 / 255 blue:239.0 / 255 alpha:1];
            
            [Enable_PRACK addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            
            BOOL Enable_PRACK_bool = [[NSUserDefaults standardUserDefaults]boolForKey:@"Enable_PRACK"];
            
            Enable_PRACK.on = Enable_PRACK_bool;
            
            //            [cell.contentView addSubview:Enable_PRACK];
            
            cell.accessoryView  =Enable_PRACK;
            
        }
        else if (indexPath.row==1){
            
            cell.textLabel.text = NSLocalizedString(@"Enable IMS",@"Enable IMS");
            
            
            Enable_IMS = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWid-60, 8, 50, 28)];
            
            Enable_IMS.onTintColor = [UIColor colorWithRed:29.0 / 255 green:172.0 / 255 blue:239.0 / 255 alpha:1];
            
            [Enable_IMS addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            
            BOOL Enable_IMS_bool = [[NSUserDefaults standardUserDefaults]boolForKey:@"Enable_IMS"];
            
            Enable_IMS.on = Enable_IMS_bool;
            
            cell.accessoryView  =Enable_IMS;
            
            
        }else if (indexPath.row==2){
            
            cell.textLabel.text = NSLocalizedString(@"Passive Session Timer",@"Passive Session Timer");
            
            
            Passive_Session_Timer = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWid-60, 8, 50, 28)];
            
            Passive_Session_Timer.onTintColor = [UIColor colorWithRed:29.0 / 255 green:172.0 / 255 blue:239.0 / 255 alpha:1];
            
            [Passive_Session_Timer addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            
            BOOL Passive_Session_Timer_bool = [[NSUserDefaults standardUserDefaults]boolForKey:@"Passive_Session_Timer"];
            
            Passive_Session_Timer.on = Passive_Session_Timer_bool;
            
            cell.accessoryView  =Passive_Session_Timer;
            
        }else if (indexPath.row==3){
            
            
            
            cell.textLabel.text = NSLocalizedString(@"Enable Early Media",@"Enable Early Media");
            
            
            Enable_Early_Media = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWid-60, 8, 50, 28)];
            
            Enable_Early_Media.onTintColor = [UIColor colorWithRed:29.0 / 255 green:172.0 / 255 blue:239.0 / 255 alpha:1];
            
            [Enable_Early_Media addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            
            BOOL Enable_Early_Media_bool = [[NSUserDefaults standardUserDefaults]boolForKey:@"Enable_Early_Media"];
            
            Enable_Early_Media.on = Enable_Early_Media_bool;
            
            cell.accessoryView  =Enable_Early_Media;
            
            
        }
        
    }
    else if (section==8){
        
        
        if (indexPath.row==0) {
            
            cell.textLabel.text = NSLocalizedString(@"Enalbe Call Record",@"Enalbe Call Record");
            
            
            Enalbe_Call_Record = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWid-60, 8, 50, 28)];
            
            Enalbe_Call_Record.onTintColor = [UIColor colorWithRed:29.0 / 255 green:172.0 / 255 blue:239.0 / 255 alpha:1];
            [Enalbe_Call_Record addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            
            BOOL Enalbe_Call_Record_bool = [[NSUserDefaults standardUserDefaults]boolForKey:@"Enalbe_Call_Record"];
            
            Enalbe_Call_Record.on = Enalbe_Call_Record_bool;
            
            cell.accessoryView  =Enalbe_Call_Record;
        }
        else if (indexPath.row==1){
            
            cell.textLabel.text = NSLocalizedString(@"All recording files",@"All recording files");
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        
        
    }
    
    return cell;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
#ifndef HAVE_VIDEO
    if (section == 4) {
        return nil;
    }
#endif
    
    
    if (section==7) {
        
        return NSLocalizedString(@"SIP MISCELLANEOUS",@"SIP MISCELLANEOUS");
    }
    
    if (section==8) {
        
        return NSLocalizedString(@"CALL RECORDING",@"CALL RECORDING");
        
    }
    
    
    if (section==2 && ![databaseManage.mOptions supportCallKit]) {
        return nil;
        
    }
    
    return NSLocalizedString(_preferencesArray[0][section], _preferencesArray[0][section]);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    
    if (section==2 && ![databaseManage.mOptions supportCallKit]) {
        return nil;
        
    }
    
    if (section == 0) {
        return NSLocalizedString(@"Enable to allow application to use your mobile data plan when WIFI is not available.", @"Enable to allow application to use your mobile data plan when WIFI is not available.");
    }
    else if (section == 1) {
        return NSLocalizedString(@"Enable to support incoming calls while in background. Enabling this option will significantly decrease battery life!", @"Enable to support incoming calls while in background. Enabling this option will significantly decrease battery life!");
    }
    else if (section == 2) {
        return NSLocalizedString(@"Receive incoming calls on your lock screen and make calls from your device's contact list.", @"Receive incoming calls on your lock screen and make calls from your device's contact list.");
    }
    return nil;
}


#pragma mark --
#pragma mark

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        NSLog(@"开");
        
        
        if (switchButton == Enable_PRACK) {
            
            [portSIPEngine enableReliableProvisional:YES];
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Enable_PRACK"];
        }
        else if (switchButton == Enable_IMS){
            
            [portSIPEngine enable3GppTags:YES];
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Enable_IMS"];
            
        }else if (switchButton ==Passive_Session_Timer){
            
            [portSIPEngine enableSessionTimer:90 refreshMode:SESSION_REFERESH_UAC];
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Passive_Session_Timer"];
        }
        else if (switchButton == Enalbe_Call_Record){
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Enalbe_Call_Record"];
        }
        else if (switchButton == Enable_Early_Media){
            
            [portSIPEngine enableEarlyMedia:YES];
            
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Enable_Early_Media"];
        }
        
    }else {
        
        if (switchButton == Enable_PRACK) {
            
            [portSIPEngine enableReliableProvisional:NO];
            
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Enable_PRACK"];
        }
        else if (switchButton == Enable_IMS){
            
            
            [portSIPEngine enable3GppTags:NO];
            
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Enable_IMS"];
            
        }else if (switchButton ==Passive_Session_Timer){
            
            [portSIPEngine disableSessionTimer];
            
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Passive_Session_Timer"];
        }
        else if (switchButton == Enalbe_Call_Record){
            
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Enalbe_Call_Record"];
        }
        
        else if (switchButton == Enable_Early_Media){
            
            [portSIPEngine enableEarlyMedia:NO];
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Enable_Early_Media"];
            
        }
    }

}

#pragma mark - TableView Delegate Method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==3) {
        [_rtpFromTextField becomeFirstResponder];
        return;
    }
    
    [_rtpFromTextField resignFirstResponder];
 
    if (indexPath.section==8 && indexPath.row==1    ) {
        AllRecordingFilesViewController *allcon = [[AllRecordingFilesViewController alloc]init];
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:allcon animated:YES];
        return;
    }
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        HSPreferencesDetailViewController *detailCtrl = nil;
        if (indexPath.section == 4 && indexPath.row == 0) {
            detailCtrl = [[HSPreferencesDetailViewController alloc] initWithArray:_preferencesDetailDict[_preferencesArray[section + 1][row]] defaultSelected:_mResolutionArray[databaseManage.mOptions.videoResolution] title:cell.textLabel.text rowIndexPath:indexPath];
        }
        else{
            detailCtrl = [[HSPreferencesDetailViewController alloc] initWithArray:_preferencesDetailDict[_preferencesArray[section + 1][row]] defaultSelected:cell.detailTextLabel.text title:cell.textLabel.text rowIndexPath:indexPath];
        }
        detailCtrl.delegate = self;
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailCtrl animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectedRowWithString:(int)selectedRow rowIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    Options* options = databaseManage.mOptions;
    
    if (section == 4){
        if (row == 0) {
            options.videoResolution = selectedRow;
        }
        else if (row == 1){
            options.videoFrameRate = (selectedRow +1) * 5;
            
            if(selectedRow ==4){
                
                options.videoFrameRate = 30;
            }
            
        }
        else if (row == 2){
            switch (selectedRow) {
                case 0:
                    options.videoBandwidth = 128;
                    break;
                case 1:
                    options.videoBandwidth = 256;
                    break;
                case 2:
                    options.videoBandwidth = 512;
                    break;
                case 3:
                    options.videoBandwidth = 1024;
                    break;
                    
                case 4:
                    options.videoBandwidth = 2048;
                    break;
                    
                default:
                    break;
            }
        }
    }
    else if (section == 5){
        options.useSRTP = selectedRow;
    }
    else if (section == 6){
        options.dtmfOfInfo = selectedRow;
    }
    
    [databaseManage saveOptions];
}

-(void)switchPressed:(id)sender
{
    NSInteger tagValue = ((UISwitch*)sender).tag;
    Options* options = databaseManage.mOptions;
    
    switch (tagValue) {
        case 1000:
            options.use3G = [sender isOn];
            break;
        case 1100:
            options.forceBackground = [sender isOn];
            break;
        case 1200:
            options.enableCallKit = [sender isOn];
            break;
            
            //        case 1302:
            //            options.enableVAD = [sender isOn];
            //            break;
            //        case 1304:
            //            options.enableCNG = [sender isOn];
            //            break;
            
        case 1403:
            options.videoNACK = [sender isOn];
            break;
        case 1500:
            options.enableForward = [sender isOn];
            break;
        case 1601:
            options.playDtmfTone = [sender isOn];
            break;
            
        default:
            break;
    }
    
    if (tagValue == 1500) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:6];
        [self.tableView beginUpdates];
        if (options.enableForward) {
            _forwardTextField.text = nil;
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else{
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];
    }
    
    [databaseManage saveOptions];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string == nil || [string isEqualToString:@""] || textField.tag == 1401) {
        return YES;
    }
    return textField.text.length < 5;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1100) {
        if ([textField.text intValue] < 1024 || [textField.text intValue] > 50000) {
            textField.text = [NSString stringWithFormat:@"%d", 10000];
        }
        Options* options = databaseManage.mOptions;
        options.rtpPortFrom = [textField.text intValue];
        [databaseManage saveOptions];
    }
    else if (textField.tag == 1401){
        Options* options = databaseManage.mOptions;
        options.forwardTo = textField.text;
        [databaseManage saveOptions];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    return YES;
}

@end
