//
//  SettingViewController.m
//  PortGo
//
//  Created by Joe Lepple on 4/19/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "SettingViewController.h"
#import "NetworkDetailViewController.h"
#import "MediaViewController.h"
#import "HSAboutDetailViewController.h"
#import "HSSettingCell.h"
#import "HSAccountTableViewController.h"
#import "LineStateViewController.h"
#import "UIColor_Hex.h"
#import "DataBaseManage.h"
#import "AppDelegate.h"
#import "CzxAccountSettingsController.h"
#import "PremiumFeaturesController.h"

#import "TextImageView.h"
#import "Masonry.h"
#import <StoreKit/StoreKit.h>



#define kSettingIndex_Account       0
#define kSettingIndex_Remmainder    1
#define kSettingIndex_Codecs        2
#define kSettingIndex_Preferences	3


#define kSettingIndex_PremiumFeatures 4

#define kSettingIndex_Premium       5
#define kSettingIndex_Help          6
#define kSettingIndex_About         7
#define kSettingIndex_Share         8

@interface SettingItem : NSObject
@property int  index;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, copy) NSString *imageName;


@end

@implementation SettingItem
@synthesize index;
@synthesize title;
@synthesize imageName;
@end

@interface SettingViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UILabel *_state;
    UIImageView *_stateIcon;
    UILabel *nameAndNumber;
    UIImageView *headerIcon;
    
    NSDictionary *callbackState;
    NSDictionary *stateDic;
    
    Account *_mAccount;
    
    TextImageView *textImageicon;
    
}
@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)editHeaderIcon:(UITapGestureRecognizer *)sender {
    
    NSLog(@"edit header icon");
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", @"Camera"), NSLocalizedString(@"Photo Liberary", @"Photo Liberary"), NSLocalizedString(@"Delete Avatar", @"Delete Avatar"),nil];
    
    
    actionSheet.tag = 615;
    
    [actionSheet showInView:self.navigationController.view];
    
    
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return ;
    }
    
    if (actionSheet.tag == 615) {
        
        
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.allowsEditing = YES;
        picker.editing = YES;
        picker.navigationBar.translucent = NO;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        switch (buttonIndex) {
                
            case 0:
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    picker.delegate=self;
                    [self presentViewController:picker animated:YES completion:^{
                        
                    }];
                }
                else {
                }
                break;
                
            case 1:
                
                
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    picker.delegate=self;
                    [self presentViewController:picker animated:YES completion:^{
                        
                    }];
                }
                
                break;
                
                
            case 2:
                
                _mAccount.usericondata  = nil;
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"usericondataBOOL"];
                
                if (_mAccount.usericondata) {
                    headerIcon.image = [UIImage imageWithData:_mAccount.usericondata];
                    
                    headerIcon.hidden = NO;
                    
                    textImageicon.hidden = YES;
                }
                else
                {
                    headerIcon.image = [UIImage imageNamed:@"user_info_head_image.png"];
                    headerIcon.hidden = YES;
                    textImageicon.hidden = NO;
                }
                
                
                break;
                
        }
        
    }
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (image) {
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0);
        
        _mAccount.usericondata = imageData;
        
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"usericondataBOOL"];
        
        [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:@"usericondata"];
        
        
        if (_mAccount.usericondata) {
            headerIcon.image = [UIImage imageWithData:_mAccount.usericondata];
            
            headerIcon.hidden = NO;
            
            textImageicon.hidden = YES;
        }
        else
        {
            headerIcon.image = [UIImage imageNamed:@"user_info_head_image.png"];
            
            headerIcon.hidden = YES;
            
            textImageicon.hidden = NO;
            
        }
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(TextImageView*)creatTextImageView{
    return textImageicon;
}


-(UIView *)createHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 230)];
    
    headerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH / 2 - 50, 20, 104, 104)];
    headerIcon.layer.cornerRadius = headerIcon.bounds.size.height / 2;
    
    textImageicon = [[TextImageView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH / 2 - 50, 20, 104, 104)];
    
    textImageicon.textImageLabel.font = [UIFont fontWithName:@"Arial" size:30];
    textImageicon.raduis = 45.0;
    textImageicon.clipsToBounds = YES;
    
    NSString * tempstr;
    if (_mAccount.userName.length < 2) {
        tempstr = _mAccount.userName;
    } else {
        tempstr = [_mAccount.userName substringToIndex:2];
    }
    textImageicon.string = tempstr;
    
    
    textImageicon.backgroundColor = [UIColor clearColor];
    
    BOOL usericondataBOOL = [[NSUserDefaults standardUserDefaults]boolForKey:@"usericondataBOOL"];
    
    if (usericondataBOOL) {
        headerIcon.image = [UIImage imageWithData:_mAccount.usericondata];
        
        headerIcon.hidden = NO;
        
        textImageicon.hidden = YES;
        
    }
    else
    {
        headerIcon.image = [UIImage imageNamed:@"user_info_head_image.png"];
        
        headerIcon.hidden = YES;
        
        textImageicon.hidden = NO;
        
        
    }
    
    
    headerIcon.clipsToBounds = YES;
    [headerView addSubview:headerIcon];
    [headerView addSubview:textImageicon];
    
    headerIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editHeaderIcon:)];
    [headerIcon addGestureRecognizer:tap];
    
    textImageicon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editHeaderIcon:)];
    [textImageicon addGestureRecognizer:tap2];
    
    
    CGFloat originY = headerIcon.frame.origin.y + headerIcon.frame.size.height;
    nameAndNumber = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2 - 100, originY + 10, 200, 30)];
    nameAndNumber.textAlignment = NSTextAlignmentCenter;
    nameAndNumber.numberOfLines = 2 ;
    
    nameAndNumber.text = shareAppDelegate.account.accountName;
    
    [headerView addSubview:nameAndNumber];
    
    [nameAndNumber setFont:[UIFont systemFontOfSize:18]];
    
    nameAndNumber .textColor = [UIColor colorWithHexString:@"#2e2e2e"];
    
    
    UILabel*  Numberlab = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2 - 100, originY + 10 +30 , 200, 30)];
    Numberlab.textAlignment = NSTextAlignmentCenter;
    Numberlab.numberOfLines = 2 ;
    
    Numberlab.text = shareAppDelegate.account.userName;
    
    [headerView addSubview:Numberlab];
    
    [Numberlab setFont:[UIFont systemFontOfSize:14]];
    
    Numberlab .textColor = [UIColor colorWithHexString:@"#929292"];
    
    
    _stateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 15, 15)];
    [headerView addSubview:_stateIcon];
    
    _state = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, 100, 25)];
    
    _state.textAlignment = NSTextAlignmentCenter;
    
    [_state setFont:[UIFont systemFontOfSize:14]];
    
    [nameAndNumber mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(headerIcon.mas_centerX);
        
        make.top.equalTo(headerIcon.mas_bottom).with.offset(0);
        
        make.width.equalTo(@(200));
        
        make.height.equalTo(@(30));
        
        
    }];
    
    [Numberlab mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(headerIcon.mas_centerX);
        
        make.top.equalTo(nameAndNumber.mas_bottom).with.offset(-5);
        
        make.width.equalTo(@(200));
        
        make.height.equalTo(@(30));
        
        
    }];
    
    
    _state.frame = CGRectMake(0, 0, 100, 25);
    _stateIcon.frame = CGRectMake(ScreenWid-100-10+8, 205, 15, 15);
    
    
    UIControl *contr = [[UIControl alloc] initWithFrame:CGRectMake(ScreenWid-100, 200, 100, 25)];
    [contr addTarget:self action:@selector(controlClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:contr];
    
    [contr addSubview:_state];
    
    UILabel * leftlab = [[UILabel alloc]initWithFrame:CGRectMake(15, 200, 100, 25)];
    
    leftlab.text = NSLocalizedString(@"Status", @"Status");
    
    [headerView addSubview:leftlab];
    
    [leftlab setFont:[UIFont systemFontOfSize:18]];
    leftlab.textColor = MAIN_COLOR;
    
    if (shareAppDelegate.portSIPHandle.SIPInitialized) {
        _state.text = NSLocalizedString(@"online", @"online");
        _stateIcon.image = [UIImage imageNamed:@"set_status_online"];
    } else {
        _state.text = NSLocalizedString(@"offline", @"offline");
        _stateIcon.image = [UIImage imageNamed:@"set_status_outline"];
    }
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, headerView.bounds.size.height - 0.5, MAIN_SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:line];
    
    return headerView;
}



#pragma  mark --
#pragma mark
-(void)controlClick:(UIControl *)sender {
    LineStateViewController *state = [[LineStateViewController alloc] init];
    if (!callbackState) {
        state.stateString = NSLocalizedString(@"online", @"online");
    } else {
        NSString *key = [callbackState allKeys][0];
        state.stateString = callbackState[key];
    }
    
    [state didSelectlineStateCallback:^(NSDictionary *state) {
        callbackState = state;
        stateDic = [state copy];
        
        [self changeselfstate];
    }];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:state animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark -onRegisterState


-(void)showonline:(BOOL)online{
    
    if (online) {
        _state.textColor= [UIColor blackColor];
        _stateIcon.image = [UIImage imageNamed:@"set_status_online"];
        
        if (stateDic) {
            NSString *key = [stateDic allKeys][0];
            _stateIcon.image = [UIImage imageNamed:key];
            
            if ([stateDic[key] isEqualToString:NSLocalizedString(@"Do not disturb", @"Do not disturb")]) {
                _stateIcon.frame = CGRectMake(ScreenWid-100-10-5-2, 205, 15, 15);
            } else {
                _stateIcon.frame = CGRectMake(ScreenWid-100-10+8, 205, 15, 15);
            }
            _state.text = stateDic[key];
        }
    }
    else
    {
        _state.text = NSLocalizedString(@"offline", @"offline");
        _state.textColor= [UIColor redColor];
        _stateIcon.image = [UIImage imageNamed:@"set_status_outline"];
    }
    
}

- (void)onRegisterState:(NSNotification*)sender
{
    NSString *state = [sender object];
    
    if ([state isEqualToString:REGISTER_STATE_SUCCESS]) {
        _state.text = NSLocalizedString(@"online", @"online");
        _state.textColor= [UIColor blackColor];
        _stateIcon.image = [UIImage imageNamed:@"set_status_online"];
    }
    else
    {
        _state.text = NSLocalizedString(@"offline", @"offline");
        _state.textColor= [UIColor redColor];
        _stateIcon.image = [UIImage imageNamed:@"set_status_outline"];
        
    }
}

#pragma mark--
#pragma mark

-(void)changeselfstate{
    
    NSString* status;
    
    if (stateDic ==nil) {
        stateDic = [[NSMutableDictionary alloc]init];
        
        stateDic = @{@"set_status_online" : NSLocalizedString(@"Online", @"Online")};
        
        status = @"Online";
    }
    else
    {
        NSString *key = [stateDic allKeys][0];
        
        if ([stateDic[key] isEqualToString:NSLocalizedString(@"online", @"online")]) {
            status = @"Available";
        }
        else if ([stateDic[key] isEqualToString:NSLocalizedString(@"Away", @"Away")]) {
            status = @"Away";
            
        }else if ([stateDic[key] isEqualToString:NSLocalizedString(@"Do not disturb", @"Do not disturb")]) {
            status = @"Do not disturb";
            
        }else if ([stateDic[key] isEqualToString:NSLocalizedString(@"Busy", @"Busy")]) {
            status = @"Busy";
            
        }else if ([stateDic[key] isEqualToString:NSLocalizedString(@"offline", @"offline")]) {
            
            status = @"offline";
        }
        
    }
    
    
    if(shareAppDelegate.portSIPHandle.mAccount.presenceAgent==1)
    {//agent
        int value = [portSIPEngine setPresenceStatus:-1 statusText:status];
        
    } else { //p2p
        NSMutableArray *arr = [contactView contacts];
        
        for (Contact *friend in arr) {
            if (friend.subscribeID && friend.subscribeID!=0) {
                [portSIPEngine setPresenceStatus:friend.subscribeID statusText:status];
            }
            
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    onlinestate = [[NSUserDefaults standardUserDefaults]boolForKey:@"setonline"];
    [self showonline:onlinestate];
    [UIApplication sharedApplication].statusBarStyle = 0;
    _mAccount = shareAppDelegate.portSIPHandle.mAccount;
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    self.tableView.backgroundColor = bkColor;
    [self.navigationController.navigationBar setBarTintColor:bkColor];
    [self.tabBarController.tabBar setBarTintColor:bkColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegisterState:) name:REGISTER_STATE object:nil];
    
    _mAccount = shareAppDelegate.portSIPHandle.mAccount;
    
    
    BOOL   usericondataBOOL = [[NSUserDefaults standardUserDefaults]boolForKey:@"usericondataBOOL"];
    
    if (usericondataBOOL) {
        
        _mAccount.usericondata = [[NSUserDefaults standardUserDefaults]objectForKey:@"usericondata"];
        
    }
    else
    {
        _mAccount.usericondata = nil;
    }
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                      NSForegroundColorAttributeName:MAIN_COLOR}];
    
    [self.navigationController.navigationBar setTintColor:MAIN_COLOR];
    
    [self.navigationController.navigationBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setBackgroundImage:[[UIImage alloc]init]];
    
    
    self.title = NSLocalizedString(@"Settings", @"Settings");
    
    self.tableView.tableHeaderView = [self createHeaderView];
    self.tableView.sectionHeaderHeight = 0.5;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    settingsItems = [NSMutableArray arrayWithCapacity:10];
    SettingItem *item = [[SettingItem alloc] init];
    item.index = kSettingIndex_Account;
    item.title = NSLocalizedString(@"Account", @"Account");
    item.imageName =  @"set_user_ico";
    [settingsItems addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = kSettingIndex_Codecs;
    item.title = NSLocalizedString(@"Codecs", @"Codecs");
    item.imageName =  @"set_codecs_ico";
    [settingsItems addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = kSettingIndex_Preferences;
    item.title = NSLocalizedString(@"Preferences", @"Preferences");
    item.imageName =  @"set_set_ico";
    [settingsItems addObject:item];
    
    
    item = [[SettingItem alloc] init];
    item.index = kSettingIndex_Premium;
    item.title = NSLocalizedString(@"Premium Features", @"Premium Features");
    item.imageName =  @"setting_premium_feature.png";
    //    [settingsItems addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = kSettingIndex_Help;
    item.title = NSLocalizedString(@"Help", @"Help");
    item.imageName =  @"setting_help.png";
    //    [settingsItems addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = kSettingIndex_About;
    item.title = NSLocalizedString(@"About", @"About");
    item.imageName =  @"set_about_ico";
    [settingsItems addObject:item];
    
    item = [[SettingItem alloc] init];
    item.index = kSettingIndex_Share;
    item.title = NSLocalizedString(@"Share", @"Share");
    item.imageName =  @"setting_share.png";
    //    [settingsItems addObject:item];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showNodistrbe:) name:@"showNodistrbe" object:nil];
    
    
    [self traitCollectionDidChange:self.traitCollection];
}

-(void)showNodistrbe:(NSNotification*)not{
    if ([not.object isEqual:@"0"]) {
        
        NSIndexPath *indexpath  = [NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexpath];
        
    }
    else if([not.object isEqual:@"1"])
    {
        NSIndexPath *indexpath  = [NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexpath];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settingsItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"HSSettingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    
    SettingItem *item = [settingsItems objectAtIndex:indexPath.row];;
    cell.imageView.image = [UIImage imageNamed:item.imageName];
    cell.textLabel.text = item.title;
    
    
    if (item.index == kSettingIndex_Remmainder) {
        cell.accessoryView = nil;
        
        UILabel *rest = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 100, 25)];
        rest.text = @"¥:0";
        rest.textAlignment = NSTextAlignmentRight;
        rest.textColor = MAIN_COLOR;
        cell.accessoryView = rest;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingItem *item = [settingsItems objectAtIndex:indexPath.row];
    
    switch (item.index) {
        case kSettingIndex_Account://account
        {
            //            HSAccountTableViewController *accountCtrl = [[HSAccountTableViewController alloc] initWithNibName:@"HSAccountTableViewController" bundle:nil];
            
            CzxAccountSettingsController *accountCtrl = [[CzxAccountSettingsController alloc] init];
            
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:accountCtrl animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
            break;
        case kSettingIndex_Remmainder:
        {
            
        }
            break;
        case kSettingIndex_Preferences://network
        {
            NetworkDetailViewController *networkDetail = [[NetworkDetailViewController alloc]initWithStyle:UITableViewStyleGrouped];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:networkDetail animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
            break;
        case kSettingIndex_Codecs:
            //codeC
        {
            MediaViewController *mediaController = [[MediaViewController alloc]initWithStyle:UITableViewStyleGrouped];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mediaController animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
            
            break;
            
            
        case kSettingIndex_PremiumFeatures:
            //PremiumFeatures
        {
            NSLog(@"PremiumFeatures");
            
            
            PremiumFeaturesController *PremiumFeatures = [[PremiumFeaturesController alloc]initWithStyle:UITableViewStyleGrouped];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:PremiumFeatures animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
            
            break;
            
            
            
            //        case kSettingIndex_Premium://premium feature
            //        {
            //            [self performSegueWithIdentifier:@"Premium" sender:nil];
            //        }
            //            break;
        case kSettingIndex_About:
            //about us
        {
            
            HSAboutDetailViewController *aboutusController = [[HSAboutDetailViewController alloc] init];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutusController animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (IBAction)unWind:(UIStoryboardSegue *)segue
{
    
}
@end
