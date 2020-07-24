//
//  HSAccountTableViewController.m
//  PortGo
//
//  Created by MrLee on 14-9-30.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSAccountTableViewController.h"
#import "Account.h"
#import "DataBaseManage.h"
#import "AppDelegate.h"
#import "HSLoginViewController.h"
#import "UIBarButtonItem+HSBackItem.h"

@interface HSAccountTableViewController ()<UIActionSheetDelegate>
{
    Account *_mAccount;
    NSArray *_mAccountLabel;
    NSMutableArray *_mAccountInfo;
    NSMutableArray *_accontInfoData;
}

@end

@implementation HSAccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Account", @"Account");

#ifndef OEM_FIXEDHOST
    _mAccountLabel = [[NSArray alloc] initWithObjects:@[NSLocalizedString(@"User Name", @"User Name"),
                                                        NSLocalizedString(@"Password", @"Password")],
                      @[NSLocalizedString(@"SIP Server", @"SIP Server"),
                        NSLocalizedString(@"Server Port", @"Server Port"),
                        NSLocalizedString(@"Transport", @"Transport")],
                      @[NSLocalizedString(@"User Domain", @"User Domain"),
                        NSLocalizedString(@"Display Name", @"Display Name"),
                        NSLocalizedString(@"Auth Name", @"Auth Name")],nil];
#else
    
    _mAccountLabel = [[NSArray alloc] initWithObjects:NSLocalizedString(@"User Name", @"User Name"),
                      NSLocalizedString(@"Password", @"Password"),
                      NSLocalizedString(@"Transport", @"Transport"),
                      NSLocalizedString(@"Display Name", @"Display Name"),
                      NSLocalizedString(@"Auth Name", @"Auth Name"),
                      @"", nil];
#endif
    _mAccount = shareAppDelegate.portSIPHandle.mAccount;
    
    _mAccountInfo = [NSMutableArray array];
    NSMutableArray * transportInfo = [NSMutableArray array];
    NSMutableArray * userInfo = [NSMutableArray array];
    if (_mAccount.userName) {
        [_mAccountInfo addObject:_mAccount.userName];
    }
    else{
        [_mAccountInfo addObject:@""];
    }
    
    [_mAccountInfo addObject:@"******"];
#ifndef OEM_FIXEDHOST
    if (_mAccount.SIPServer) {
        [transportInfo addObject:_mAccount.SIPServer];
    }
    else{
        [transportInfo addObject:@""];
    }
    
    if (_mAccount.SIPServerPort) {
        [transportInfo addObject:[NSString stringWithFormat:@"%d", _mAccount.SIPServerPort]];
    }
    else{
        [transportInfo addObject:@""];
    }
#endif
    if (_mAccount.transportType) {
        [transportInfo addObject:[NSString stringWithFormat:@"%@", _mAccount.transportType]];
    }
    else{
        [transportInfo addObject:@""];
    }
#ifndef OEM_FIXEDHOST
    if (_mAccount.userDomain) {
        [userInfo addObject:_mAccount.userDomain];
    }
    else{
        [userInfo addObject:@""];
    }
#endif
    if (_mAccount.displayName) {
        [userInfo addObject:_mAccount.displayName];
    }
    else{
        [userInfo addObject:@""];
    }
    
    if (_mAccount.authName) {
        [userInfo addObject:_mAccount.authName];
    }
    else{
        [userInfo addObject:@""];
    }
    
    _accontInfoData = [NSMutableArray arrayWithObjects:_mAccountInfo, transportInfo, userInfo, nil];
    
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
}

- (void)viewWillAppear:(BOOL)animated{
    [self traitCollectionDidChange:self.traitCollection];
}
- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logoutHandle:(UIControlEvents*)event
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Sign Out", @"Sign Out") otherButtonTitles:nil];
    [actionSheet showInView:self.navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _mAccountLabel.count + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == _mAccountLabel.count || section == _mAccountLabel.count + 1) {
        return 1;
    }
    NSArray *arr = _mAccountLabel[section];
    return arr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if (indexPath.section == _accontInfoData.count + 1) {
        
        UILabel *logout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width, 44)];
        logout.text = NSLocalizedString(@"Sign Out", @"Sign Out");
        logout.textAlignment = NSTextAlignmentCenter;
        logout.textColor = [UIColor redColor];
        [cell.contentView addSubview:logout];
        cell.userInteractionEnabled = YES;
        
        return cell;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    
    if (indexPath.section == _accontInfoData.count) {
        cell.textLabel.text = NSLocalizedString(@"Voice Mail", @"Voice Mail");
        cell.detailTextLabel.text = _mAccount.voiceMail;
        
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    NSArray *infoRows = _accontInfoData[indexPath.section];
    NSArray *labelRows = _mAccountLabel[indexPath.section];
    if (infoRows.count > indexPath.row && labelRows.count > indexPath.row) {
        cell.textLabel.text = labelRows[indexPath.row];
        cell.detailTextLabel.text = infoRows[indexPath.row];
    }
    
    // Configure the cell...
    cell.userInteractionEnabled = NO;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self logoutHandle:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
