//
//  HSAdvanceOptionsViewController.m
//  PortGo
//
//  Created by portsip on 17/4/17.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSAdvanceOptionsViewController.h"
#import "DataBaseManage.h"
#import "HSLoginViewController.h"
#import "HSAboutDetailViewController.h"
#import "UIColor_Hex.h"

#define kTextFieldWidth  175.0f
#define kTextFieldHeight 25.0f
#define kLeftMargin      105.0f
#define kRightMargin     5.0f

@interface HSAdvanceOptionsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *advanceOptionsTableView;

@end

@implementation HSAdvanceOptionsViewController
{
    NSArray* _sectionTitles;
    NSArray* _outDelegateArry;
    NSArray* _transportProtocol;
    NSArray* _stunList;
    NSIndexPath* _lastSelectIndex;
    
    UITextField* _displayTextField;
    UITextField* _outProxyServerField;
    UITextField* _authNameField;
    UITextField* _stunServerField;
    UITextField* _portTextField;
    UITextField* _voiceMailField;
    
    CGRect _tableViewFrame;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    
    _topView.backgroundColor = bkColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.titleLabel.text = NSLocalizedString(@"Advance", @"Advance");
    self.titleLabel.textColor = MAIN_COLOR;
    //sectionTitles
    _sectionTitles = @[NSLocalizedString(@"ACCOUNT ADDITIONAL", @"ACCOUNT ADDITIONAL"), NSLocalizedString(@"Transport", @"Transport"),NSLocalizedString(@"STUN",@"STUN"), NSLocalizedString(@"TLS CERT MANAGEMENT", @"TLS CERT MANAGEMENT"),@"", @""];
    
    //rows
    _outDelegateArry = @[NSLocalizedString(@"Outbound Proxy", @"Outbound Proxy"), NSLocalizedString(@"Auth Name", @"Auth Name"), NSLocalizedString(@"Display Name", @"Display Name"), NSLocalizedString(@"Voice Mail", @"Voice Mail")];
    _transportProtocol = @[@"UDP",@"TLS",@"TCP",@"PERS_UDP",@"PERS_TCP"];
    
    
    _stunList = @[NSLocalizedString(@"Enable STUN", @"Enable Stun"),
                  NSLocalizedString(@"Server", @"Server"),
                  NSLocalizedString(@"Port", @"Port")];
    
    
    _displayTextField = [self getDisplayTextField];
    _outProxyServerField = [self getOutProxySeverTextField];
    _authNameField = [self getAuthNameTextfield];
    _stunServerField = [self getServerAdressTextfield];
    _portTextField = [self getPortTextfield];
    _voiceMailField = [self getVoiceMailTextfield];
    
    _advanceOptionsTableView.rowHeight = 44;
    _advanceOptionsTableView.sectionFooterHeight = 0.1;
    _advanceOptionsTableView.tableHeaderView.backgroundColor = [UIColor colorWithHexString:@"#f4f3f3" alpha:1];
    _advanceOptionsTableView.delegate = self;
    _advanceOptionsTableView.dataSource = self;
    [_advanceOptionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellid"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self traitCollectionDidChange:self.traitCollection];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    if (!_portTextField.isFirstResponder && !_stunServerField.isFirstResponder && !_voiceMailField.isFirstResponder) {
        return ;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGFloat tranformValue = keyboardTop - self.view.frame.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.advanceOptionsTableView.transform = CGAffineTransformMakeTranslation(0, tranformValue + 150);
    }];
    
}

-(void) scrollToBottom:(BOOL)animated
{
    [_advanceOptionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_stunList.count - 1) inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.advanceOptionsTableView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
#ifdef MUSLIMSIM
    
    return _sectionTitles.count-1;
    
#endif
    
    
    return _sectionTitles.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.advanceOptionsTableView.bounds.size.width, 40)];
    
    if (@available(iOS 11.0, *)) {
        sectionView.backgroundColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        sectionView.backgroundColor = [UIColor whiteColor];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 250, 30)];
    titleLabel.text = _sectionTitles[section];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.font = [UIFont systemFontOfSize:12];
    [sectionView addSubview:titleLabel];
    return sectionView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 4 || section ==5) {
        return 20.0;
    }
    return 40.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    else if (section == 1) {
        return 5 ;
    }
    else if (section == 2) {
        return 3;
    }
    
    return 1 ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    //    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    
    if (section == 0)
    {
        if (row == 0) {
            cell.textLabel.text = [_outDelegateArry objectAtIndex:0];
            _outProxyServerField.textColor = [UIColor darkGrayColor];
            _outProxyServerField.font = [UIFont fontWithName:@"Helvetica" size:14];;
            _outProxyServerField.backgroundColor = [UIColor clearColor];
            _outProxyServerField.borderStyle = UITextBorderStyleNone;
            _outProxyServerField.autocorrectionType = UITextAutocorrectionTypeNo;
            _outProxyServerField.delegate = self;
            cell.accessoryView = _outProxyServerField;
        }
        else if(row == 1) {
            cell.textLabel.text = [_outDelegateArry objectAtIndex:1];
            _authNameField.textColor = [UIColor darkGrayColor];
            _authNameField.font = [UIFont fontWithName:@"Helvetica" size:15];;
            _authNameField.backgroundColor = [UIColor clearColor];
            _authNameField.borderStyle = UITextBorderStyleNone;
            _authNameField.autocorrectionType = UITextAutocorrectionTypeNo;
            _authNameField.delegate = self;
            cell.accessoryView = _authNameField;
        }
        else if (row == 2) {
            cell.textLabel.text = [_outDelegateArry objectAtIndex:2];
            _displayTextField.textColor = [UIColor darkGrayColor];
            _displayTextField.font = [UIFont fontWithName:@"Helvetica" size:15];
            _displayTextField.backgroundColor = [UIColor clearColor];
            _displayTextField.borderStyle = UITextBorderStyleNone;
            _displayTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            _displayTextField.delegate = self;
            cell.accessoryView = _displayTextField;
            
        }
        else if (row == 3){
            cell.textLabel.text = NSLocalizedString(@"Voice Mail", @"Voice Mail");
            _voiceMailField.textColor = [UIColor darkGrayColor];
            _voiceMailField.font = [UIFont fontWithName:@"Helvetica" size:15];;
            _voiceMailField.backgroundColor = [UIColor clearColor];
            _voiceMailField.borderStyle = UITextBorderStyleNone;
            _voiceMailField.autocorrectionType = UITextAutocorrectionTypeNo;
            _voiceMailField.delegate = self;
            
            
            _voiceMailField.placeholder =NSLocalizedString(@"Voice Mail", @"Voice Mail");
            NSLog(@"_voiceMailField.text%@",_voiceMailField.text);
            
            NSLog(@"_voiceaccount.voiceMaMail=%@",_account.voiceMail);
            
            _voiceMailField.text = _account.voiceMail;
            
            cell.accessoryView = _voiceMailField;
        }
        
    }
    else if (section == 1)
    {
        cell.textLabel.text = _transportProtocol[row];
        
        NSLog(@"transportType=====%@",_account.transportType);
        
        
        
        
        if ([cell.textLabel.text isEqualToString:_account.transportType]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _lastSelectIndex = indexPath;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if ([_account.transportType isEqualToString:@"(null)"] ) {
            
            if (indexPath.row==0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        
        
    }
    else if (section == 2)
    {
        cell.textLabel.text = [_stunList objectAtIndex:row];
        if (row == 0) {
            UISwitch *switchOperation = [[UISwitch alloc]init];
            switchOperation.tag = 6666;
            switchOperation.onTintColor = MAIN_COLOR;
            [switchOperation addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
            switchOperation.on = (_account.enableSTUN != 0);
            //                switchOperation.on = (databaseManage.mOptions.enableSTUN != 0);
            cell.accessoryView = switchOperation;
        }
        else if (row == 1) {
            _stunServerField.textColor = [UIColor darkGrayColor];
            _stunServerField.font = [UIFont fontWithName:@"Helvetica" size:15];;
            _stunServerField.backgroundColor = [UIColor clearColor];
            _stunServerField.borderStyle = UITextBorderStyleNone;
            _stunServerField.autocorrectionType = UITextAutocorrectionTypeNo;
            _stunServerField.delegate = self;
            cell.accessoryView = _stunServerField;
            
            if (!_account.enableSTUN) {
                
                _stunServerField.userInteractionEnabled  =NO;
            }else
            {
                _stunServerField.userInteractionEnabled  =YES;
            }
            
        }
        else if (row == 2) {
            _portTextField.textColor = [UIColor darkGrayColor];
            _portTextField.font = [UIFont fontWithName:@"Helvetica" size:15];;
            _portTextField.backgroundColor = [UIColor clearColor];
            _portTextField.borderStyle = UITextBorderStyleNone;
            _portTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            _portTextField.delegate = self;
            cell.accessoryView = _portTextField;
            
            
            if (!_account.enableSTUN) {
                
                _portTextField.userInteractionEnabled  =NO;
            }else
            {
                _portTextField.userInteractionEnabled  =YES;
            }
        }
    }
    else if (section == 3) {
        cell.textLabel.text = NSLocalizedString(@"Verify TLS Cert", @"Verify TLS Cert");
        UISwitch *switchOperation = [[UISwitch alloc]init];
        switchOperation.onTintColor = MAIN_COLOR;
        switchOperation.tag = 8888;
        [switchOperation addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
        switchOperation.on = (_account.useCert != 0);
        
        
        NSLog(@"_account.useCert=====%d",_account.useCert);
        
        cell.accessoryView = switchOperation;
    }
    else if (section == 4)
    {
        cell.textLabel.text = NSLocalizedString(@"Enable Logging", @"Enable Logging");
        UISwitch *switchOperation = [[UISwitch alloc]init];
        switchOperation.onTintColor = MAIN_COLOR;
        switchOperation.tag = 9999;
        [switchOperation addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
        switchOperation.on = (_account.isOpenlog != 0);
        cell.accessoryView = switchOperation;
    }
    else if (section == 5) {
        cell.textLabel.text =  NSLocalizedString(@"About", @"About");
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        if (indexPath.section != 5) {
            return ;
        }
        
        HSAboutDetailViewController* about = [[HSAboutDetailViewController alloc] initWithNibName:@"HSAboutDetailViewController" bundle:nil];
        about.modalPresentationStyle = UIModalPresentationFullScreen;
        about.inadvance = YES;
        
        self.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:about animated:YES completion:nil];
        
        
        //   [self.navigationController pushViewController:about animated:YES];
        
        
        
    }
    else {
        if (indexPath == _lastSelectIndex) {
            return ;
        }
        UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:_lastSelectIndex];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
        _lastSelectIndex = indexPath;
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        _account.transportType = newCell.textLabel.text;
        
        [tableView reloadData];
    }
}

-(void)switchPressed:(UISwitch *)sender {
    if (sender.tag == 6666) {
        _account.enableSTUN = [sender isOn];
    }
    else if (sender.tag == 7777) { //presence agent
        _account.presenceAgent = [sender isOn];
        
        databaseManage.mOptions.presenceAgent = [sender isOn];
        [databaseManage saveOptions];
    }
    else if (sender.tag == 8888) {
        _account.useCert = [sender isOn];
    }
    else {
        _account.isOpenlog = [sender isOn];
    }
    
    [_advanceOptionsTableView reloadData];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}

-(UITextField *)getDisplayTextField {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *displayTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    if ([_account.displayName isEqualToString:@"(null)"]) {
        _displayTextField.text = nil ;
    }
    else {
        displayTextField.text = _account.displayName;
    }
    displayTextField.keyboardType = UIKeyboardTypeDefault;
    displayTextField.textAlignment = NSTextAlignmentRight;
    displayTextField.returnKeyType = UIReturnKeyDone;
    
    displayTextField.placeholder = NSLocalizedString(@"[username is the default]", @"[username is the default]");
    
    return displayTextField;
}

#pragma mark - getOutProxySeverTextField

-(UITextField *)getOutProxySeverTextField {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *outDelegateTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    
    if ([_account.userDomain isEqualToString:@"(null)"]) {
        outDelegateTextField.text = nil;
    } else {
        outDelegateTextField.text = _account.SIPServer;
        if ([_account.SIPServer isEqualToString:@"(null)"]||[[_account.SIPServer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0){
            outDelegateTextField.text = nil;
        }else{
            if(_account.SIPServerPort  !=5060) {
                outDelegateTextField.text = [NSString stringWithFormat:@"%@:%d", _account.SIPServer,_account.SIPServerPort];
            }else{
                outDelegateTextField.text = _account.SIPServer;;
            }
        }
    }
    
    outDelegateTextField.placeholder = NSLocalizedString(@"[domain is the default]", @"[domain is the default]");
    outDelegateTextField.keyboardType = UIKeyboardTypeDefault;
    outDelegateTextField.textAlignment = NSTextAlignmentRight;
    outDelegateTextField.returnKeyType = UIReturnKeyDone;
    return outDelegateTextField;
}

-(UITextField *)getAuthNameTextfield {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *authNameTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    if ([_account.authName isEqualToString:@"(null)"]) {
        authNameTextField.text = nil ;
    } else {
        authNameTextField.text = _account.authName;
    }
    authNameTextField.placeholder = NSLocalizedString(@"[username is the default]", @"[username is the default]");
    authNameTextField.keyboardType = UIKeyboardTypeDefault;
    authNameTextField.textAlignment = NSTextAlignmentRight;
    authNameTextField.returnKeyType = UIReturnKeyDone;
    return authNameTextField;
}

-(UITextField *)getServerAdressTextfield {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *serverAddressTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    
    serverAddressTextField.text = !_account.STUNServer ? DEFALUT_OPTIONS_NATT_STUN_SERVER : _account.STUNServer;
    
    serverAddressTextField.keyboardType = UIKeyboardTypeDefault;
    serverAddressTextField.textAlignment = NSTextAlignmentRight;
    serverAddressTextField.returnKeyType = UIReturnKeyDone;
    return serverAddressTextField;
}

-(UITextField *)getPortTextfield {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *portTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    portTextField.text = [[NSString alloc] initWithFormat:@"%d",!_account.STUNPort ? DEFALUT_OPTIONS_NATT_STUN_PORT : _account.STUNPort];;
    portTextField.keyboardType = UIKeyboardTypeNumberPad;
    portTextField.textAlignment = NSTextAlignmentRight;
    portTextField.returnKeyType = UIReturnKeyDone;
    return portTextField;
}

-(UITextField *)getVoiceMailTextfield {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *VMTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    if (_account.voiceMail) {
        VMTextField.text = [[NSString alloc] initWithFormat:@"%@",_account.voiceMail];
    }
    VMTextField.keyboardType = UIKeyboardTypeDefault;
    VMTextField.textAlignment = NSTextAlignmentRight;
    VMTextField.returnKeyType = UIReturnKeyDone;
    return VMTextField;
}

-(UITextField *)getPublishRefreshtextField {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *PRTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    if (_account.publishRefresh) {
        PRTextField.text = [[NSString alloc] initWithFormat:@"%d",_account.publishRefresh];
    }
    PRTextField.keyboardType = UIKeyboardTypeNumberPad;
    PRTextField.textAlignment = NSTextAlignmentRight;
    PRTextField.returnKeyType = UIReturnKeyDone;
    return PRTextField;
}

-(UITextField *)getSubscribeRefreshTextField {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *SRTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    if (_account.subscribeRefresh) {
        SRTextField.text = [[NSString alloc] initWithFormat:@"%d",_account.subscribeRefresh];
    }
    SRTextField.keyboardType = UIKeyboardTypeNumberPad;
    SRTextField.textAlignment = NSTextAlignmentRight;
    SRTextField.returnKeyType = UIReturnKeyDone;
    return SRTextField;
}

#pragma mark - backAction
- (IBAction)backAction:(id)sender {
    
    _account.displayName = _displayTextField.text;
    _account.authName = _authNameField.text;
    _account.voiceMail = _voiceMailField.text;
    
    NSString* temp = _outProxyServerField.text;
    //
    if (temp.length >0) {
        
        if ([temp rangeOfString:@":"].location != NSNotFound) {
            NSArray* arr = [temp componentsSeparatedByString:@":"];
            _account.SIPServer = arr[0];
            _account.SIPServerPort = [arr[1] intValue];
        } else {
            _account.SIPServer = temp;
            _account.SIPServerPort = 5060;
        }
        
    }else{
        _account.SIPServer =@"";
        _account.SIPServerPort = _account.SIPServerPort==0?5060: _account.SIPServerPort;
    }
    
    NSLog(@"_mAccount.SIPServer===%@\n    _mAccount.userDomain%@",_account.SIPServer ,  _account.userDomain);
    
    
    _account.publishRefresh =  300;
    _account.subscribeRefresh =300;
    _account.STUNServer = [_stunServerField.text isEqualToString:@""] ? DEFALUT_OPTIONS_NATT_STUN_SERVER : _stunServerField.text;
    _account.STUNPort = [_portTextField.text isEqualToString:@""] ? DEFALUT_OPTIONS_NATT_STUN_PORT : [_portTextField.text intValue];
    //    [databaseManage saveActiveAccount:_account reset:NO];
    
    _account.presenceAgent = databaseManage.mOptions.presenceAgent ;
    
    [self.delegate didSetOptionWith:_account];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
