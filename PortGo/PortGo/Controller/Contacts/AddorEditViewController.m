//
//  AddorEditViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/6/7.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "AddorEditViewController.h"
#import "MarkViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+InterfaceOrientation.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "SipFriend.h"
#import "DataBaseManage.h"
#import "IMEditViewController.h"
#import "IQKeyboardManager.h"
#import "Masonry.h"


#define ADDIPCALL @"AddIPCall"
#define ADDPHONE @"AddPhone"

#define kTextFieldWidth  175.0f
#define kTextFieldHeight 25.0f
#define KeyBoardHeight 258

#define FromContactView 2555
#define FromContactDetailViewRow 2666
#define FromContactDetailViewNavitem 2333
#define FromNumberPadView 2444
#define FromContactListView 2777
#define FromChatView 2888

#define FromAddFriend 2689

#define FromFriendAddor 2988


#define FromCallList  2998


@interface AddorEditViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate,UIScrollViewDelegate>
{
    NSData *_imageData;
    BOOL _hasHeaderIcon;
    CGFloat bottomOfTable;
    UITextField *_editingFeild;
    NSString *imAddress;
    
    UIButton * deletebutton;
    
}
@end

@implementation AddorEditViewController

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [_IPCallNumbers removeAllObjects];
    [self.phoneNumbers removeAllObjects];
    _IPCallNumbers = nil;
    self.phoneNumbers = nil;
}

-(void)initNavigationBarWithTitle:(NSString *)title RightItem:(NSString *)rightTitle {
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStylePlain target:self action:@selector(navigationBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = right;
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cacelAction)];
    self.navigationItem.leftBarButtonItem = left;
    
    self.navigationController.navigationBar.tintColor = MAIN_COLOR;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    titleLabel.textColor = MAIN_COLOR;
    titleLabel.text = title;
    
    self.navigationItem.titleView = titleLabel;
    
}

-(void)configureTableView {
    
    
    _IPCallTablView = [[UITableView alloc]init];
    
    _phoneCallTablview = [[UITableView alloc]init];
    
    _deleteTableview = [[UITableView alloc]init];
    
    
    
    [_IPCallTablView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseID"];
    [_phoneCallTablview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseID"];
    
    _IPCallTablView.delegate = self;
    _IPCallTablView.dataSource = self;
    _IPCallTablView.allowsSelectionDuringEditing = YES;
    
    _phoneCallTablview.delegate = self;
    _phoneCallTablview.dataSource = self;
    _phoneCallTablview.allowsSelectionDuringEditing = YES;
    
    [_phoneCallTablview setEditing:YES animated:NO];
    [_IPCallTablView setEditing:YES animated:NO];
    
    [_phoneCallTablview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"dele"];
    
    _deleteTableview .delegate =self;
    _deleteTableview.dataSource =self;
    _deleteTableview.scrollEnabled = NO;
    
    [self resetUI2];
}

-(void)initNumbers {
    self.phoneNumbers = [NSMutableArray arrayWithObject:@{NSLocalizedString(@"Add PhoneNumber", @"Add PhoneNumber") : ADDPHONE}];
    
    _IPCallNumbers = [NSMutableArray arrayWithObjects:@{NSLocalizedString(@"Add VoIP Number", @"Add VoIP Number") : ADDIPCALL}, @{NSLocalizedString(@"IM Address", @"IM Address") : NSLocalizedString(@"No IM",@"No IM")}, nil];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



-(void)locallizedUI {
    _firstNamelabel.text = NSLocalizedString(@"FirstName", @"FirstName");
    
    _lastNameLabel.text = NSLocalizedString(@"LastName", @"LastName");
    _companyLabel.text = NSLocalizedString(@"Company", @"Company");
    _partmentLabel.text = NSLocalizedString(@"Department", @"Department");
    _jobLabel.text = NSLocalizedString(@"JobTitle", @"JobTitle");
    
    _firstNamelabel.textColor = MAIN_COLOR;
    _lastNameLabel.textColor = MAIN_COLOR;
    _companyLabel.textColor = MAIN_COLOR;
    _partmentLabel.textColor = MAIN_COLOR;
    _jobLabel.textColor = MAIN_COLOR;
    
    _firstNameTextFeild.placeholder = NSLocalizedString(@"Enter FirstName", @"Enter FirstName");
    _lastNameTextFeild.placeholder = NSLocalizedString(@"Enter LastName", @"Enter LastName");
    _companytextFeild.placeholder = NSLocalizedString(@"Enter CompanyName", @"Enter CompanyName");
    _partmentFeild.placeholder = NSLocalizedString(@"Enter Department", @"Enter Department");
    _jobTextFeild.placeholder = NSLocalizedString(@"Enter Jobtitle", @"Enter Jobtitle");
    
}

#pragma mark - viewDidLoad

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    
    self.backGroundScroll.backgroundColor = bkColor;
    self.headerView.backgroundColor = bkColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //_backGroundScroll.backgroundColor = RGB(243, 243, 243);
    
    _hasHeaderIcon = NO;
    [self initNumbers];
    
    
    if (_recognizeID == FromNumberPadView || _recognizeID == FromContactDetailViewRow || _recognizeID == FromChatView ||  _recognizeID==FromCallList ||  _recognizeID ==FromAddFriend) { //numberPadView
        [self initNavigationBarWithTitle:NSLocalizedString(@"Add Contact", @"Add Contact") RightItem:NSLocalizedString(@"Save", @"Save")];
        
        
        
        if (_numbPadenterString && ![_numbPadenterString isEqualToString:@""] && ![_numbPadenterString isEqualToString:@" "]) {
            if ([_numbPadenterString containsString:@"@"]) {
                
                NSDictionary *dic = [NSDictionary dictionaryWithObject:_numbPadenterString forKey:NSLocalizedString(@"VoIP Call", @"VoIP Call")];
                [_IPCallNumbers insertObject:dic atIndex:0];
            } else {
                NSDictionary *dic2 = [NSDictionary dictionaryWithObject:_numbPadenterString forKey:[CNLabeledValue localizedStringForLabel:CNLabelHome]];
                [self.phoneNumbers insertObject:dic2 atIndex:0];
                
            }
        }
        
        if (_recognizeID ==FromAddFriend) {
            
            _firstNameTextFeild.text = _addfriendname;
            
        }
        
    }
    else if (_recognizeID == FromContactDetailViewNavitem || _recognizeID == FromContactListView) { //contactDetailView
        
        [self initNavigationBarWithTitle:NSLocalizedString(@"Edit Contact", @"Edit Contact") RightItem:NSLocalizedString(@"Save", @"Save")];
        
        _firstNameTextFeild.text = self.aContact.firstName;
        _lastNameTextFeild.text = self.aContact.lastName;
        _companytextFeild.text = self.aContact.company;
        _partmentFeild.text = self.aContact.partment;
        _jobTextFeild.text = self.aContact.jobtitle;
        
        if (self.aContact.IMNumber) {
            imAddress = self.aContact.IMNumber;
        }
        
        for (NgnPhoneNumber *number in self.aContact.phoneNumbers) {
            //            NSDictionary* dic = [NSDictionary dictionaryWithObject:number.number forKey:number.description];
            
            NSLog(@"number====%@",number);
            
            NSDictionary* dic;
            
            if ([number.number containsString:@"@"]){
                
                dic = [NSDictionary dictionaryWithObject:number.number forKey:NSLocalizedString(@"VoIP Call", @"VoIP Call")];
                
                
                [_IPCallNumbers insertObject:dic atIndex:0];
            }else{
                dic = [NSDictionary dictionaryWithObject:number.number forKey:number.description];
                [self.phoneNumbers insertObject:dic atIndex:0];
            }
            
            
        }
        
        
        
        for (NSDictionary *dic in  self.aContact.IPCallNumbers) {
            
            [_IPCallNumbers insertObject:dic atIndex:0];
        }
        
        
        if (_addvoidcall) {
            
            [_IPCallNumbers insertObject:_addvoidcall atIndex:0];
            
        }
        
        
    }else if (_recognizeID == FromContactView) {
        [self initNavigationBarWithTitle:NSLocalizedString(@"Add Contact", @"Add Contact") RightItem:NSLocalizedString(@"Save", @"Save")];
    }
    
    
    [self configureTableView];
    
    if (self.aContact.contdentifier !=nil){
        
        
        _deleteTableview.hidden = NO;
        
    }else
    {
        
        _deleteTableview.hidden = YES;
    }
    
    
    if(_recognizeID == FromNumberPadView){
        
        _deleteTableview.hidden = YES;
        
    }
    
    _firstNameTextFeild.delegate = self;
    _lastNameTextFeild.delegate = self;
    _companytextFeild.delegate = self;
    _partmentFeild.delegate = self;
    _jobTextFeild.delegate = self;
    //   [_firstNameTextFeild becomeFirstResponder];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoraedWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [self locallizedUI];
    
    
    _backGroundScroll.delegate = self;
    [self traitCollectionDidChange:self.traitCollection];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //   [IQKeyboardManager sharedManager].enable = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewwilldisapper");
    
    //  [IQKeyboardManager sharedManager].enable = NO;
}




-(void)keyBoardWillShow:(NSNotification *)notif {
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardTop = keyboardRect.origin.y;
    bottomOfTable = keyboardTop;
    
    if  (_editingFeild ==  _lastNameTextFeild ||  _editingFeild ==  _firstNameTextFeild  ||  _editingFeild ==  _jobTextFeild || _editingFeild ==  _companytextFeild || _editingFeild ==  _partmentFeild ){
        
    }
    else
    {
        
        [_backGroundScroll setFrame:CGRectMake(0, -keyboardRect.size.height, ScreenWid, ScreenHeight)];
        
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if (translation.y>0) {
        [_editingFeild resignFirstResponder];
    }
    
}

-(void)keyBoraedWillHidden:(NSNotification *)notif {
    [_backGroundScroll setFrame:CGRectMake(0, 0, ScreenWid, ScreenHeight)];
    
}


-(void)resetUI2{
    CGFloat IPheight = _IPCallNumbers.count * 44;
    //    _headerView.frame = CGRectMake(0, 0, ScreenWid, 300);
    CGFloat phoneHeight = self.phoneNumbers.count  * 44;
    
    _backGroundScroll.contentSize = CGSizeMake(0, 300+150+ IPheight + phoneHeight +44+20 );
    
    [_backGroundScroll addSubview:_IPCallTablView];
    [_backGroundScroll addSubview:_phoneCallTablview];
    [_backGroundScroll addSubview:_deleteTableview];
    
    _IPCallTablView.frame  = CGRectMake(0, 350, ScreenWid, IPheight);
    
    _phoneCallTablview.frame  = CGRectMake(0, 350+50+IPheight, ScreenWid, phoneHeight);
    
    _deleteTableview.frame  = CGRectMake(0, 350+50+IPheight+50+phoneHeight -20, ScreenWid, 44);
    
    
    
}


#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
    
}


-(void)deleteContact{
    
    
    NSArray *keyFentch = @[CNContactFamilyNameKey, CNContactGivenNameKey,CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactSocialProfilesKey, CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactInstantMessageAddressesKey];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    
    CNMutableContact *    contact = [[store unifiedContactWithIdentifier:self.aContact.contdentifier keysToFetch:keyFentch error:nil] mutableCopy];
    
    
    [self removeContact:contact];
    
    [shareAppDelegate.contactViewController editContactHasDoneFromDetailViewController];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"shuaxin1" object:nil];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"backContackView" object:nil];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == _deleteTableview) {
        
        return 1;
    }
    
    if (tableView == _IPCallTablView) {
        return _IPCallNumbers.count;
    }
    
    return self.phoneNumbers.count ;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
    
    
    if (tableView == _deleteTableview) {
        
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dele"];
        
        deletebutton = [[UIButton alloc]init];
        
        deletebutton.frame = CGRectMake(0, 0, ScreenWid/2, 44);
        
        NSString * temp = NSLocalizedString(@"Delete Contact",@"Delete Contact");
        
        [deletebutton setTitle:[NSString stringWithFormat:@"          %@",temp] forState:UIControlStateNormal];
        
        deletebutton .titleLabel.font = [UIFont systemFontOfSize:14];
        
        [deletebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        deletebutton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        deletebutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [deletebutton addTarget:self action:@selector(deleteContact) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:deletebutton];
        
        return cell;
    }
    
    static NSString *resuseid = @"reuseID";
    
    if (tableView == _IPCallTablView) {
        UITableViewCell *IPcell = [tableView dequeueReusableCellWithIdentifier:resuseid forIndexPath:indexPath];
        if (!IPcell) {
            IPcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseid];
        }
        
        IPcell.editingAccessoryView = nil;
        
        IPcell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if (indexPath.row == _IPCallNumbers.count - 1) {
            NSDictionary *dic = _IPCallNumbers[indexPath.row];
            NSString *key = [dic allKeys][0];
            IPcell.textLabel.text = key;
            IPcell.textLabel.textColor = MAIN_COLOR;
            IPcell.detailTextLabel.text = dic[key];
            IPcell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return IPcell;
        }
        
        NSDictionary *dic = _IPCallNumbers[indexPath.row];
        NSString *key = [dic allKeys][0];
        NSString *value = [dic objectForKey:key];
        
        
        
        IPcell.textLabel.text = key;
        IPcell.textLabel.textColor = MAIN_COLOR;
        
        if ([value isEqualToString:ADDIPCALL]) {
            return IPcell;
        }
        
        UITextField *displayTextField = [self getTextFeildWeatherIPCall:YES];
        displayTextField.text = value;
        
        
        
        displayTextField.textColor = [UIColor darkGrayColor];
        displayTextField.font = [UIFont systemFontOfSize:15];
        displayTextField.backgroundColor = [UIColor clearColor];
        displayTextField.borderStyle = UITextBorderStyleNone;
        displayTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        displayTextField.delegate = self;
        displayTextField.tag = 100 + indexPath.row;
        IPcell.editingAccessoryView = displayTextField;
        
        return IPcell;
    }
    
    
    
    
    UITableViewCell *phoneCell = [tableView dequeueReusableCellWithIdentifier:resuseid forIndexPath:indexPath];
    if (!phoneCell) {
        phoneCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseid];
    }
    phoneCell.editingAccessoryView = nil;
    
    phoneCell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    NSDictionary *dic = self.phoneNumbers[indexPath.row];
    NSString *key = [dic allKeys][0];
    NSString *value = [dic objectForKey:key];
    
    
    
    
    phoneCell.textLabel.text = key;
    phoneCell.textLabel.textColor = MAIN_COLOR;
    
    if ([value isEqualToString:ADDPHONE]) {
        return phoneCell;
    }
    
    UITextField *displayTextField1 = [self getTextFeildWeatherIPCall:NO];
    
    displayTextField1.text = value;
    
    displayTextField1.textColor = [UIColor darkGrayColor];
    displayTextField1.font = [UIFont systemFontOfSize:15];
    displayTextField1.backgroundColor = [UIColor clearColor];
    displayTextField1.borderStyle = UITextBorderStyleNone;
    displayTextField1.autocorrectionType = UITextAutocorrectionTypeNo;
    displayTextField1.delegate = self;
    displayTextField1.tag = 200 + indexPath.row;
    phoneCell.editingAccessoryView = displayTextField1;
    
    return phoneCell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0] animated:NO];
    
    if (tableView == _phoneCallTablview) {
        
        if (indexPath.row == self.phoneNumbers.count - 1) {
            [self.phoneNumbers insertObject:@{[CNLabeledValue localizedStringForLabel:CNLabelHome]:@""} atIndex:indexPath.row];
            [self.phoneCallTablview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            UITableViewCell *cell = [self.phoneCallTablview cellForRowAtIndexPath:indexPath];
            UITextField *textField = (UITextField *)cell.editingAccessoryView;
            [textField becomeFirstResponder];
            
            [self resetUI2];
            
            return;
        }
        MarkViewController *mark = [[MarkViewController alloc] init];
        mark.info = self.phoneNumbers[indexPath.row];
        [mark didMarkSelectedCallBack:^(NSString *mark) {
            
            UITableViewCell *cell = [self.phoneCallTablview cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = mark;
            UITextField *textFeild = (UITextField *)cell.editingAccessoryView;
            
            NSDictionary *dic = self.phoneNumbers[indexPath.row];
            NSString *lastKey = [dic allKeys][0];
            NSString *value = [dic objectForKey:lastKey];
            textFeild.text = value;
            
            dic = [NSDictionary dictionaryWithObject:value forKey:mark];
            
            [self.phoneNumbers removeObjectAtIndex:indexPath.row];
            [self.phoneNumbers insertObject:dic atIndex:indexPath.row];
            
        }];
    }
    else if (tableView == _IPCallTablView) {
        if (indexPath.row == _IPCallNumbers.count - 2) {
            [self.IPCallNumbers insertObject:@{NSLocalizedString(@"VoIP Call", @"VoIP Call"):@""} atIndex:indexPath.row];
            [self.IPCallTablView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            UITableViewCell *cell = [self.IPCallTablView cellForRowAtIndexPath:indexPath];
            UITextField *textField = (UITextField *)cell.editingAccessoryView;
            [textField becomeFirstResponder];
            
            [self resetUI2];
        }
        else if (indexPath.row == _IPCallNumbers.count - 1) { //IM地址选择
            [_editingFeild resignFirstResponder];
            
            IMEditViewController *edit = [[IMEditViewController alloc] init];
            edit.IMAddresses = [_IPCallNumbers mutableCopy];
            edit.contacrIM = _aContact.IMNumber;
            [edit didIMAddressSaved:^(NSString *imnuber) {
                self->imAddress = imnuber;
            }];
            [self.navigationController pushViewController:edit animated:YES];
        }
    }
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _IPCallTablView) {
        NSDictionary *dic = _IPCallNumbers[indexPath.row];
        NSString *key = [dic allKeys][0];
        NSString *value = dic[key];
        
        if (indexPath.row == _IPCallNumbers.count - 1) {
            return UITableViewCellEditingStyleNone;
        }
        
        if ([value isEqualToString:ADDIPCALL]) {
            return UITableViewCellEditingStyleInsert;
        }
        return UITableViewCellEditingStyleDelete;
    }
    NSDictionary *dic = self.phoneNumbers[indexPath.row];
    NSString *key = [dic allKeys][0];
    NSString *value = dic[key];
    if ([value isEqualToString:ADDPHONE]) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == _IPCallTablView) {
            NSDictionary *dic = _IPCallNumbers[index];
            NSString *key = [dic allKeys][0];
            if([dic[[dic allKeys][0]] isEqualToString:imAddress]){
                imAddress = @"";
            }
            [self.IPCallNumbers removeObjectAtIndex:index];
            [self.IPCallTablView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else if (tableView == _phoneCallTablview) {
            [self.phoneNumbers removeObjectAtIndex:index];
            [self.phoneCallTablview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (tableView == _IPCallTablView) {
            [self.IPCallNumbers insertObject:@{NSLocalizedString(@"VoIP Call", @"VoIP Call"):@""} atIndex:index];
            [self.IPCallTablView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
        }
        else if (tableView == _phoneCallTablview) {
            [self.phoneNumbers insertObject:@{[CNLabeledValue localizedStringForLabel:CNLabelHome]:@""} atIndex:index];
            [self.phoneCallTablview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
    [self resetUI2];
    
}

-(void)didContactEditedCallback:(EditContactCompleted)callback {
    self.completBlock = callback;
}
-(void)didAddHistoryToContactCallback:(AddHistoryToContact)callback {
    self.addCompletBlock = callback;
}

-(void)didEditHistoryToContactCallback:(EditHistoryToContact)callback {
    self.editCompletBlock = callback;
}

-(void)didAddChatContactCallback:(AddChatContact)callback {
    self.chatContactBlock = callback;
}

-(void)saveSystemContact {
    
    
    NSString *firstName = _firstNameTextFeild.text;
    NSString *lastName = _lastNameTextFeild.text;
    NSString *company = _companytextFeild.text;
    NSString *partment = _partmentFeild.text;
    NSString *job = _jobTextFeild.text;
    
    
    
    if ((!firstName || [firstName isEqualToString:@""]) && (!lastName || [lastName isEqualToString:@""])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice!", @"Notice!") message:NSLocalizedString(@"Please enter one of LastName and FirtName at least", @"Please enter one of LastName and FirtName at least") delegate:nil cancelButtonTitle:NSLocalizedString(@"Know That", @"Know That") otherButtonTitles:nil, nil];
        [alert show];
        
        [_firstNameTextFeild becomeFirstResponder];
        
        return;
    }
    
    CNMutableContact *contact = nil;
    
    if (self.recognizeID == FromContactView || self.recognizeID == FromNumberPadView || self.recognizeID == FromContactDetailViewRow || self.recognizeID == FromChatView ||  self.recognizeID == FromCallList || self.recognizeID ==FromAddFriend) {
        
        contact = [[CNMutableContact alloc] init];
        [self editOrAddContactWith:firstName LastName:lastName organizationName:company departmentName:partment jobTitleName:job forCNContact:contact];
        [self addContact:contact];
        
    } else {
        
        NSArray *keyFentch = @[CNContactFamilyNameKey, CNContactGivenNameKey,CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactSocialProfilesKey, CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactInstantMessageAddressesKey];
        
        CNContactStore *store = [[CNContactStore alloc] init];
        
        if (self.aContact.contdentifier ==nil) {
            
            contact = [[CNMutableContact alloc] init];
            [self editOrAddContactWith:firstName LastName:lastName organizationName:company departmentName:partment jobTitleName:job forCNContact:contact];
            [self addContact:contact];
            
            
        }
        else
        {
            contact = [[store unifiedContactWithIdentifier:self.aContact.contdentifier keysToFetch:keyFentch error:nil] mutableCopy];
            
            [self editOrAddContactWith:firstName LastName:lastName organizationName:company departmentName:partment jobTitleName:job forCNContact:contact];
            
            [self updateContact:contact];
            
        }
        
    }
    
    [shareAppDelegate.contactViewController editContactHasDoneFromDetailViewController];
    
    if (self.recognizeID == FromContactDetailViewNavitem) {
        
        Contact *conta = [[Contact alloc] initWithCNContact:contact];
        if (self.completBlock) {
            self.completBlock(conta);
        }
    }
    
    if (self.recognizeID == FromContactDetailViewRow) {
        if (self.addCompletBlock) {
            self.addCompletBlock();
        }
    }
    
    if (self.recognizeID == FromContactListView) {
        if (self.editCompletBlock) {
            self.editCompletBlock();
        }
    }
    
    if (self.recognizeID == FromChatView) {
        Contact *cont = [[Contact alloc] initWithCNContact:contact];
        if (self.chatContactBlock) {
            self.chatContactBlock(cont);
        }
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"shuaxin1" object:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeNameRefresh" object:nil];
    
    
    
    if (_addvoidcall ){
        
        _addvoidcall = nil;
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"existinghuishangye" object:nil];
        return;
        
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveSipContact {
    NSString *firstName = _firstNameTextFeild.text;
    NSString *lastName = _lastNameTextFeild.text;
    NSString *company = _companytextFeild.text;
    NSString *partment = _partmentFeild.text;
    NSString *job = _jobTextFeild.text;
    
    if ((!firstName || [firstName isEqualToString:@""]) && (!lastName || [lastName isEqualToString:@""])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice!" message:@"请输入至少姓和名中的一个" delegate:nil cancelButtonTitle:@"Know That" otherButtonTitles:nil, nil];
        [alert show];
        
        [_firstNameTextFeild becomeFirstResponder];
        
        return;
    }
    NSDictionary *dic = nil;
    NSMutableString *ipnumbers = [[NSMutableString alloc] init];
    for (NSDictionary *tempDic in _IPCallNumbers) {
        NSString *key = [tempDic allKeys][0];
        NSString *value = tempDic[key];
        if ([value isEqualToString:NSLocalizedString(@"AddIPCall", @"AddIPCall")] || [value isEqualToString:NSLocalizedString(@"No IM", @"No IM")]) {
            continue;
        }
        NSData * data = [NSJSONSerialization dataWithJSONObject:tempDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dicStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [ipnumbers appendString:dicStr];
        [ipnumbers appendString:@"|"];
    }
    
    NSString *imaddress = nil;
    if (imAddress && ![imAddress isEqualToString:@""]) {
        imaddress = imAddress;
    } else {
        if (_IPCallNumbers.count > 0) {
            NSDictionary *dic = _IPCallNumbers[0];
            NSString *key = [dic allKeys][0];
            imaddress = dic[key];
        }
    }
    
    if (![imAddress containsString:@"@"]) {
    }
    
    long subscribeid = [portSIPEngine presenceSubscribe:imaddress subject:@"Online"]; //添加好友向目标发送订阅消息
    
    Contact *sipfriend = [[Contact alloc] initWithIdentifi:-1 SunbscribeID:-1 DisplayName:[NSString stringWithFormat:@"%@%@",firstName,lastName] Firstname:firstName Lastname:lastName Company:company Department:partment Jobtitle:job IMNumber:imaddress Comfrom:0 DeletFlag:0  ApplyState:PS_ApplyStateNone   PhoneNumbers:@"" IPNumbers:ipnumbers];
    
    sipfriend.IMNumber = imaddress;
    sipfriend.outSubscribeId = subscribeid;
    
    if (_IPCallNumbers.count > 0 && [sipfriend.IMNumber isEqualToString:@""]) {
        dic = _IPCallNumbers[0];
        NSString *key = [dic allKeys][0];
        sipfriend.IMNumber = dic[key];
    }
    NSLog(@"sipfriend.IMNumbe===%@",sipfriend.IMNumber);
    
    
    if (self.recognizeID == FromContactView || self.recognizeID == FromNumberPadView || self.recognizeID == FromContactDetailViewRow || self.recognizeID == FromChatView){
        NSArray *arr = [contactView getSipContacts];
        if (arr.count == 0) {
            sipfriend.onlineState = NSLocalizedString(@"offline", @"offline");
            [contactView addSipContacts:sipfriend];
            [databaseManage insertSipFriend:sipfriend];
        } else {
            for (Contact *cont in arr) {
                if ([cont.displayName isEqualToString:sipfriend.displayName]) {
                    sipfriend.onlineState = cont.onlineState;
                    [contactView editSipContacts:sipfriend];
                    [databaseManage updateSipFriend:sipfriend];
                } else {
                    sipfriend.onlineState = NSLocalizedString(@"offline", @"offline");
                    [contactView addSipContacts:sipfriend];
                    [databaseManage insertSipFriend:sipfriend];
                }
            }
        }
        
    } else {
        [contactView editSipContacts:sipfriend];
        [databaseManage updateSipFriend:sipfriend];
    }
    
    [shareAppDelegate.contactViewController editSipcontactDoneFromDetailViewController];
    
    if (self.recognizeID == FromContactDetailViewNavitem) {
        
        if (self.completBlock) {
            self.completBlock(sipfriend);
        }
    }
    
    if (self.recognizeID == FromContactDetailViewRow) {
        if (self.addCompletBlock) {
            self.addCompletBlock();
        }
    }
    
    if (self.recognizeID == FromContactListView) {
        if (self.editCompletBlock) {
            self.editCompletBlock();
        }
    }
    
    if (self.recognizeID == FromChatView) {
        if (self.chatContactBlock) {
            self.chatContactBlock(sipfriend);
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)navigationBarButtonAction:(UIBarButtonItem *)item {
    
    [_editingFeild endEditing:YES];
    
    if (self.segmentSelect == 0) {
        [self saveSystemContact];
        
        
    }
    else if (self.segmentSelect == 1) {
        //[self saveSipContact];
        [self saveSystemContact];
        
    }
    else if (self.segmentSelect == 2) {
        
        
        [self saveSystemContact];
    }
    
}

-(void)editOrAddContactWith:(NSString *)firstName LastName:(NSString *)lastName organizationName:(NSString *)organizName departmentName:(NSString *)departmentName jobTitleName:(NSString *)jobTitle forCNContact:(CNMutableContact *)contact{
    contact.familyName = firstName;
    contact.givenName = lastName;
    contact.organizationName = organizName;
    contact.departmentName = departmentName;
    contact.jobTitle = jobTitle;
    
    
    
    NSMutableArray *socials = [NSMutableArray array];
    
    for (NSDictionary *dic in _IPCallNumbers) {
        NSString *key = [dic allKeys][0];
        NSString *value = dic[key];
        
        if (![value isEqualToString:@""] && ![value isEqualToString:ADDIPCALL] && ![key isEqualToString:NSLocalizedString(@"IM Address", @"IM Address")]) {
            CNSocialProfile *profile = [[CNSocialProfile alloc] initWithUrlString:value username:value userIdentifier:self.aContact.contdentifier service:key];
            CNLabeledValue *socialProfile = [CNLabeledValue labeledValueWithLabel:CNSocialProfileServiceKey value:profile];
            [socials addObject:socialProfile];
        }
    }
    contact.socialProfiles = socials;
    
    NSMutableArray *mobilePhones = [NSMutableArray array];
    
    for (NSDictionary *phone in self.phoneNumbers) {
        NSString *key = [phone allKeys][0];
        NSString *value = [phone objectForKey:key];
        if (![value isEqualToString:@""] && ![value isEqualToString:ADDPHONE]) {
            CNPhoneNumber *mobileNumber = [[CNPhoneNumber alloc] initWithStringValue:value];
            CNLabeledValue *mobilePhone = [[CNLabeledValue alloc] initWithLabel:key value:mobileNumber];
            [mobilePhones addObject:mobilePhone];
        }
    }
    contact.phoneNumbers = mobilePhones;
    
    
    if (self.recognizeID == FromAddFriend) {
        
        imAddress = _numbPadenterString;
    }
    
    if ([imAddress isEqual:[NSNull null]] || imAddress==NULL || imAddress ==nil
        || [imAddress isEqualToString:@"AddIPCall"]  ||  [imAddress isEqualToString:@""]) {
        NSMutableArray *imsArr = [[NSMutableArray alloc] init];
        contact.instantMessageAddresses = imsArr;
        
    }
    else
    {
        
        CNInstantMessageAddress *IMSData = [[CNInstantMessageAddress alloc]initWithUsername:imAddress service:@"IM"];
        CNLabeledValue *IMS = [CNLabeledValue labeledValueWithLabel:nil value:IMSData];
        
        contact.instantMessageAddresses = @[IMS];
        long subscribeid = [portSIPEngine presenceSubscribe:imAddress subject:@"Online"];
        
    }
    
}

- (NSArray *)queryContactWithName:(NSString *)name{
    CNContactStore *store = [[CNContactStore alloc] init];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingName:name];
    NSArray *contact = [store unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactGivenNameKey] error:nil];
    return contact;
}

-(void)removeContact:(CNMutableContact*)contact{
    
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest deleteContact:contact];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store executeSaveRequest:saveRequest error:nil];
}

/*
 Add Contact
 */


-(void)addContact:(CNMutableContact *)contact {
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest addContact:contact toContainerWithIdentifier:nil];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store executeSaveRequest:saveRequest error:nil];
}

/*
 Update Contact
 */
- (void)updateContact:(CNMutableContact *)contact{
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest updateContact:contact];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store executeSaveRequest:saveRequest error:nil];
}

-(void)cacelAction {
    
    if (_addvoidcall  ) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITextFeildDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    _editingFeild = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag >= 100 && textField.tag < 200) { //IPCallTableview
        NSInteger row = textField.tag - 100;
        NSDictionary *dic = _IPCallNumbers[row];
        NSString *key = [dic allKeys][0];
        NSString *value = dic[key];
        
        if (![textField.text isEqualToString:@" "] && ![textField.text isEqualToString:@""]) {
            NSMutableDictionary *copy = [NSMutableDictionary dictionaryWithDictionary:dic];
            
            value = textField.text;
            [copy setObject:value forKey:key];
            
            [_IPCallNumbers removeObjectAtIndex:row];
            [_IPCallNumbers insertObject:copy atIndex:row];
        }
    }
    else if (textField.tag >= 200) { // phoneTableview
        NSInteger row = textField.tag - 200;
        NSDictionary *dic = self.phoneNumbers[row];
        NSString *key = [dic allKeys][0];
        NSString *value = dic[key];
        
        if (![textField.text isEqualToString:@" "] && ![textField.text isEqualToString:@""]) {
            NSMutableDictionary *copy = [NSMutableDictionary dictionaryWithDictionary:dic];
            
            value = textField.text;
            [copy setObject:value forKey:key];
            
            [self.phoneNumbers removeObjectAtIndex:row];
            [self.phoneNumbers insertObject:copy atIndex:row];
        }
    }
}

-(UITextField *)getTextFeildWeatherIPCall:(BOOL)isIPCall {
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *displayTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    if (isIPCall) {
        displayTextField.keyboardType = UIKeyboardTypeAlphabet;
        displayTextField.placeholder = @"SIP URI";
    } else {
        displayTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    displayTextField.textAlignment = NSTextAlignmentLeft;
    displayTextField.returnKeyType = UIReturnKeyDone;
    return displayTextField;
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
