//
//  ContactDetailsViewController.m
//  PortGo
//
//  Created by Joe Lepple on 4/10/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "ContactDetailsViewController.h"
#import "PhoneEntryCell.h"
#import "AppDelegate.h"
#import "UIImage+HSImage.h"
#import "UIBarButtonItem+HSBackItem.h"
#import "NSString+HSFilterString.h"
#import "Contact.h"
#import "PeoplePicker.h"
#import "Favoriter.h"
#import "ContactDetailViewCell.h"
#import "HistoryDetailCell.h"
#import "History.h"
#import "AddorEditViewController.h"
#import "TextImageView.h"
#import "ContactListViewController.h"
#import "AddToExistingContactTableViewController.h"

#import "Masonry.h"


#define kTagActionSheetTextMessage				1
#define kTagActionSheetVideoCall				2
#define kTagActionSheetAudioCall                3

#define HistoryDeatailIdenti @"HistoryDetailCellID"

@interface ContactDetailsViewController ()<ABNewPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate ,UIActionSheetDelegate,UIImagePickerControllerDelegate> {
    UIBarButtonItem *buttonItem;
    UIButton *editorButton;
    UIButton *completeButton ;
    
    UIButton *favorateButton;
    
    BOOL _isEditing;
    ABPersonViewController *viewController;
    TextImageView *textImage;
    NSMutableArray *_dataSource;
    
    NSInteger historyCount;
    BOOL _isPersonSelectgroup;
    NSInteger currentButtonIndex;
    
    UIImage *headerImage;
    
    BOOL _contactExist;
    
    BOOL _popBack;
}
@property (weak, nonatomic) IBOutlet UIView *headerInfoView;
@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UIImageView *lineStateImageView;
@property (weak, nonatomic) IBOutlet UILabel *lineStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *workingInfo;
@property (weak, nonatomic) IBOutlet UIView *callOptionView;
@property (weak, nonatomic) IBOutlet UITableView *historyDitailTable;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) NSMutableDictionary *historyDic;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *audioCallButton;

@property (weak, nonatomic) IBOutlet UIButton *videoCallButton;

@end

@implementation ContactDetailsViewController
@synthesize viewHeader;

@synthesize contact;
@synthesize superControllerID;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

-(void)constructData {
    
    _historyDic = [NSMutableDictionary dictionary];
    
    NSMutableArray *callArray = [databaseManage selectHistory:0 byMediaType:MediaType_AudioVideo  LocalUri:AppDelegate.sharedInstance.account.userName orderBYDESC:NO needCount:NO];
    NSString *lastDate = @"$";
    
    NSMutableArray *lastArry = nil;
    for (History* call in callArray)
    {
        if(!call || ![call.mRemoteParty isEqualToString: self.callHistory.mRemoteParty] || !(call.mMediaType & MediaType_AudioVideo) || self.callHistory.mStatus != call.mStatus || self.callHistory.mMediaType != call.mMediaType){
            continue;
        }
        
        historyCount ++;
        if (historyCount > self.callHistory.historyCount) {
            historyCount -= 1;
            return ;
        }
        
        NSString *timeStart = [call getDetailsTimeStart];
        NSArray *cutTime = [timeStart componentsSeparatedByString:@", "];
        
        NSString *currentDate = cutTime[0];
        if (![currentDate isEqualToString:lastDate]) {
            lastDate = currentDate;
            lastArry = [[NSMutableArray alloc] init];
            [_historyDic setObject:lastArry forKey:lastDate];
        }
        [lastArry addObject:call];
    }
}

-(void)resetheader:(BOOL)flag {
    if (flag) {
        _workingInfo.hidden = NO;
        
        CGRect headFrame = _headerInfoView.frame;
        headFrame.size.height = 195;
        _headerInfoView.frame = headFrame;
        
        CGRect callActionFrame = _callOptionView.frame;
        callActionFrame.origin.y = 195;
        _callOptionView.frame = callActionFrame;
        
        CGRect tableHeaderFrame = self.viewHeader.frame;
        tableHeaderFrame.size.height = 250;
        self.viewHeader.frame = tableHeaderFrame;
        
        
        [_lineStateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contactName.mas_centerX);
            make.top.equalTo(_contactName.mas_bottom).with.offset(10);
            make.width.equalTo(@(100));
            make.height.equalTo(@(30));
            
        }];
        
        
        [_lineStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(_lineStateLabel.mas_centerY);
            make.right.equalTo(_lineStateLabel.mas_left).with.offset(0);
            make.width.equalTo(@(15));
            make.height.equalTo(@(15));
        }];
        
        
    } else {
        
        _workingInfo.hidden = YES;
        
        CGRect headFrame = _headerInfoView.frame;
        headFrame.size.height = 195;
        _headerInfoView.frame = headFrame;
        
        CGRect callActionFrame = _callOptionView.frame;
        callActionFrame.origin.y = 195;
        _callOptionView.frame = callActionFrame;
        
        CGRect tableHeaderFrame = self.viewHeader.frame;
        tableHeaderFrame.size.height = 250;
        self.viewHeader.frame = tableHeaderFrame;
    }
}

-(void)resizeButtonContent:(UIButton *)resizeBtn {
    
    if ([resizeBtn.titleLabel.text isEqualToString:NSLocalizedString(@"Message", @"Message")]) {
        resizeBtn.imageEdgeInsets = UIEdgeInsetsMake(-11, 22, 11, -22);
        resizeBtn.titleEdgeInsets = UIEdgeInsetsMake(11, -8, -11, 8);
    } else {
        resizeBtn.imageEdgeInsets = UIEdgeInsetsMake(-11, 22, 11, -22);
        resizeBtn.titleEdgeInsets = UIEdgeInsetsMake(11, -17, -11, 17);
    }
}


-(void)backContackView{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)mas{
    
    CGFloat  win = ScreenWid/3;
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_callOptionView.mas_left).with.offset(0);
        make.top.mas_equalTo(_callOptionView.mas_top).with.offset(0);
        make.width.equalTo(@(win));
        make.height.equalTo(@(55));
    }];
    
    
    [_audioCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_messageButton.mas_right).with.offset(0);
        make.top.mas_equalTo(_callOptionView.mas_top).with.offset(0);
        make.width.equalTo(@(win));
        make.height.equalTo(@(55));
    }];
    
    
    [_videoCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_audioCallButton.mas_right).with.offset(0);
        make.top.mas_equalTo(_callOptionView.mas_top).with.offset(0);
        make.width.equalTo(@(win));
        make.height.equalTo(@(55));
    }];
}

#pragma mark -
#pragma mark viewDidLoad
-(void)viewWillAppear:(BOOL)animated
{
    
    [self refreshUI];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_popBack) {
        _popBack = !_popBack;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor,* bkColorLight,*mainColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
        bkColorLight = [UIColor colorNamed:@"mainBKColorLight"];
        mainColor =[UIColor colorNamed:@"mainColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
        bkColorLight = [UIColor lightGrayColor];
        mainColor = MAIN_COLOR;
    }
    
    _audioCallButton.backgroundColor= bkColor;
    _videoCallButton.backgroundColor= bkColor;
    _messageButton.backgroundColor= bkColor;
    self.view.backgroundColor = bkColor;
    self.viewHeader.backgroundColor = bkColorLight;
    self.headerInfoView.backgroundColor = bkColorLight;
    self.navigationController.navigationBar.tintColor = mainColor;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self mas] ;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backContackView) name:@"backContackView" object:nil];
    
    [_messageButton setTitle:NSLocalizedString(@"Message", @"Message") forState:(UIControlState)UIControlStateNormal];
    
    [_audioCallButton setTitle:NSLocalizedString(@"Audio Call", @"Audio Call") forState:(UIControlState)UIControlStateNormal];
    
    [_videoCallButton setTitle:NSLocalizedString(@"Video Call", @"Video Call") forState:(UIControlState)UIControlStateNormal];
    [self resizeButtonContent:_messageButton];
    [self resizeButtonContent:_audioCallButton];
    [self resizeButtonContent:_videoCallButton];
    
    self.imageViewAvatar.layer.cornerRadius = self.imageViewAvatar.bounds.size.width / 2;
    self.imageViewAvatar.clipsToBounds = YES;
    
    
    if (_ifFormPhoneCallList) {
        
        self.navigationItem.title = NSLocalizedString(@"Call Detail", @"Call Detail");
        [self constructData];
        self.historyDitailTable.hidden = NO;
        [self.historyDitailTable registerNib:[UINib nibWithNibName:@"HistoryDetailCell" bundle:nil] forCellReuseIdentifier:HistoryDeatailIdenti];
        
        
        if (self.contact.contdentifier!=nil){
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editContact:)];
        }
        
        [self resetheader:NO];
        
    }else
    {
        
        [self resetheader:YES];
        self.historyDitailTable.hidden = YES;
        
        self.navigationItem.title = NSLocalizedString(@"Contact Detail", @"Contact Detail");
        CGRect headerFrame = self.viewHeader.frame;
        self.viewHeader.frame = headerFrame;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editContact:)];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap:)];
    self.viewHeader.userInteractionEnabled = YES;
    [self.viewHeader addGestureRecognizer:tap];
    
    self.tableView.tableHeaderView = self.viewHeader;
    
#ifndef HAVE_VIDEO
#ifndef HAVE_IM
    [_videoCallButton removeFromSuperview];
    [_messageButton removeFromSuperview];
#else
    messageCenter = _messageButton.center;
    messageCenter.x = (_audioCallButton.center.x + _messageButton.center.x) / 2;
    [_messageButton setCenter:messageCenter];
    
    audioCenter = _audioCallButton.center;
    audioCenter.x = (_videoCallButton.center.x + _audioCallButton.center.x) / 2;
    [_audioCallButton setCenter:audioCenter];
    [_videoCallButton removeFromSuperview];
#endif//HAVE_IM
    
#else//HAVE_VIDEO
#ifndef HAVE_IM
    videoCenter = _videoCallButton.center;
    videoCenter.x = (_videoCallButton.center.x + _audioCallButton.center.x) / 2;
    [_videoCallButton setCenter:videoCenter];
    
    audioCenter = _audioCallButton.center;
    audioCenter.x = (_audioCallButton.center.x + _messageButton.center.x) / 2;
    [_audioCallButton setCenter:audioCenter];
    [_messageButton removeFromSuperview];
#endif//HAVE_IM
#endif
    [self traitCollectionDidChange:self.traitCollection];
}

-(void)headerTap:(UITapGestureRecognizer *)sender {
    
    if (!self.contact.contdentifier) {
        return;
    }
    
    CGPoint point = [sender locationInView:self.viewHeader];
    if (CGRectContainsPoint(self.imageViewAvatar.frame, point)) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", @"Camera"), NSLocalizedString(@"Photo Liberary", @"Photo Liberary"), NSLocalizedString(@"Delete Avatar", @"Delete Avatar"),nil];
        
        actionSheet.tag = 100;
        [actionSheet showInView:self.navigationController.view];
    }
}

-(NSMutableArray *)myFavoraites {
    NSMutableArray *arr = [databaseManage loadFavorites];
    return arr;
}

-(void)loadData {
    
}

#pragma mark - refreshUI
-(void)refreshUI {
    
    if (self.superControllerID != 7) {
        _dataSource = [NSMutableArray arrayWithArray:self.contact.IPCallNumbers];
        [_dataSource addObjectsFromArray:self.contact.phoneNumbers];
        
        NSString *display = nil;
        if (contact.displayName && ![contact.displayName isEqualToString:@""]) {
            display = contact.displayName;
        } else {
            display = [contact.firstName isEqualToString:@""] ? contact.lastName : contact.firstName;
        }
        
        if(display.length<2){
            display = @" ";
        }
        
        self.contactName.text = display;
        
        if(self.contact){
            if(self.contact.picture || headerImage){
                _imageViewAvatar.image = headerImage == nil ? [UIImage imageWithData:self.contact.picture] : headerImage;
            } else {
                _imageViewAvatar.hidden = YES;
                textImage.hidden = NO;
                if (!textImage) {
                    textImage = [[TextImageView alloc] initWithFrame:_imageViewAvatar.frame];
                    textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:27];
                    textImage.raduis = 27 ;
                    textImage.layer.cornerRadius = textImage.bounds.size.width / 2;
                    textImage.clipsToBounds = YES;
                    [_headerInfoView addSubview:textImage];
                    
                    [textImage mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.top.mas_equalTo(self.view.mas_top).with.offset(30);
                        make.width.equalTo(@(65));
                        make.height.equalTo(@(65));
                        make.centerX.equalTo(_headerInfoView);
                    }];
                }
                
                if ([self includeChinese:display]) {
                    if (display.length < 2) {
                        textImage.string = [display substringToIndex:1];
                    } else {
                        NSString *substring = [display substringToIndex:2];
                        
                        if ([self includeChinese:substring]) {
                            textImage.textImageLabel.text = [display substringToIndex:1];
                        } else {
                            textImage.textImageLabel.text = [display substringToIndex:2];
                        }
                    }
                    
                } else
                {
                    if (display.length >= 2) {
                        
                        NSString * tempstr = [display substringFromIndex:display.length-1];
                        
                        if ([display containsString:@" "] &&  ![tempstr isEqualToString:@" "]) {
                            NSArray *strs = [display componentsSeparatedByString:@" "];
                            NSString *first = strs[0];
                            NSString *last = strs[1];
                            
                            if (first.length >=1 &&  last.length >=1) {
                                textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
                            }
                            else
                            {
                                if (first.length<1  && last.length>=1) {
                                    textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",@"",[last substringToIndex:1]];
                                }
                                if (last.length<1 && first.length >=1) {
                                    textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],@""];
                                }
                                
                            }
                            
                        } else {
                            if (display.length >=2) {
                                textImage.textImageLabel.text = [display substringToIndex:2];
                            }
                        }
                    } else {
                        if (display.length == 0) {
                            
                            if (display.length >=2) {
                                textImage.string = [display substringToIndex:2];
                            }
                        } else {
                            if (display.length >=1) {
                                textImage.string = [display substringToIndex:1];
                            }
                            
                        }
                    }
                }
            }
            
            _lineStateLabel.text=contact.stateText;
            
            if ([contact.stateText isEqualToString:NSLocalizedString(@"Available", @"Available")]) {
                
                _lineStateImageView.image = [UIImage imageNamed:@"set_status_online"];
            }
            else if ([contact.stateText isEqualToString:NSLocalizedString(@"Away", @"Away")]){
                
                _lineStateImageView.image = [UIImage imageNamed:@"set_status_away"];
            }
            else if ([contact.stateText isEqualToString:NSLocalizedString(@"Do not disturb", @"Do not disturb")]){
                
                _lineStateImageView.image = [UIImage imageNamed:@"set_status_shutup"];
            }
            else if ([contact.stateText isEqualToString:NSLocalizedString(@"Busy", @"Busy")]){
                
                _lineStateImageView.image = [UIImage imageNamed:@"mid_content_status_busy_ico"];
            }
            else if ([contact.stateText isEqualToString:NSLocalizedString(@"offline", @"offline")]){
                
                _lineStateImageView.image = [UIImage imageNamed:@"set_status_outline"];
            }
        }
        
    }
    else { //self.superControllerID = 7
        CGRect tableFrame = self.historyDitailTable.frame;
        tableFrame.size.height = (35*historyCount) + (28 * [_historyDic allKeys].count) ;
        self.historyDitailTable.frame = tableFrame;
        CGRect frame = self.viewHeader.frame;
        frame.size.height = 250 + self.historyDitailTable.frame.size.height;
        self.viewHeader.frame = frame;
        self.tableView.tableHeaderView = self.viewHeader;
        
        Contact *searchContact = [contactView getContactByPhoneNumber:self.callHistory.mRemoteParty];
        if (!searchContact) {
            _contactExist = NO;
        } else {
            _contactExist = YES;
        }
        
        self.contactName.text = self.callHistory.mRemoteParty;
        
        _imageViewAvatar.hidden = YES;
        if (!textImage) {
            textImage = [[TextImageView alloc] initWithFrame:_imageViewAvatar.frame];
            textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:27];
            textImage.raduis = 27 ;
            textImage.layer.cornerRadius = textImage.bounds.size.width / 2;
            textImage.clipsToBounds = YES;
            [_headerInfoView addSubview:textImage];
        }
        if (self.callHistory.mRemoteParty.length > 2) {
            textImage.textImageLabel.text = [self.callHistory.mRemoteParty substringToIndex:2];
        } else {
            textImage.textImageLabel.text = [self.callHistory.mRemoteParty substringToIndex:1];
        }
        
        if (self.contact.company || self.contact.partment || self.contact.jobtitle) {
            self.workingInfo.hidden = NO;
            self.workingInfo.text = [NSString stringWithFormat:@"%@ %@ %@", self.contact.company, self.contact.partment, self.contact.jobtitle];
        } else {
            //            [self resetheader:NO];
            self.workingInfo.hidden = YES;
        }
        
        _lineStateLabel.text=searchContact.stateText;
        
        if ([searchContact.stateText isEqualToString:NSLocalizedString(@"Available", @"Available")]) {
            
            _lineStateImageView.image = [UIImage imageNamed:@"set_status_online"];
        }
        else if ([searchContact.stateText isEqualToString:NSLocalizedString(@"Away", @"Away")]){
            
            _lineStateImageView.image = [UIImage imageNamed:@"set_status_away"];
        }
        else if ([searchContact.stateText isEqualToString:NSLocalizedString(@"Do not disturb", @"Do not disturb")]){
            
            _lineStateImageView.image = [UIImage imageNamed:@"set_status_shutup"];
        }
        else if ([searchContact.stateText isEqualToString:NSLocalizedString(@"Busy", @"Busy")]){
            
            _lineStateImageView.image = [UIImage imageNamed:@"mid_content_status_busy_ico"];
        }
        else if ([searchContact.stateText isEqualToString:NSLocalizedString(@"offline", @"offline")]){
            
            _lineStateImageView.image = [UIImage imageNamed:@"set_status_outline"];
        }
        
    }
    
    
    if (_ifFormPhoneCallList) {
        CGRect tableFrame = self.historyDitailTable.frame;
        CGFloat hi = (35*historyCount) + (28 * [_historyDic allKeys].count) ;
        self.historyDitailTable.frame = tableFrame;
        [self.historyDitailTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_callOptionView.mas_left).with.offset(0);
            make.top.equalTo(_callOptionView.mas_bottom).with.offset(0);
            make.width.equalTo(@(ScreenWid));
            make.height.equalTo(@(hi));
        }];
        
        CGRect frame = self.viewHeader.frame;
        frame.size.height = 250 + self.historyDitailTable.frame.size.height;
        
        [self.historyDitailTable mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_callOptionView.mas_left).with.offset(0);
            make.top.equalTo(_callOptionView.mas_bottom).with.offset(0);
            make.width.equalTo(@(ScreenWid));
            make.height.equalTo(@(hi+_headerInfoView.frame.size.height));
        }];
        
        self.tableView.tableHeaderView = self.viewHeader;
        
    }
    
    [self.tableView reloadData];
}

- (BOOL)includeChinese:(NSString *)predicateStr
{
    for(int i=0; i< [predicateStr length];i++)
    {
        int a = [predicateStr characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)contactDetailGroupDidChangedCallback:(ContactDetaildidChangeGroup)callback {
    self.callback = callback;
}

#pragma mark - editContact

-(void)editContact:(id)sender {
    
    AddorEditViewController *edit = [[AddorEditViewController alloc] init];
    edit.modalPresentationStyle = UIModalPresentationFullScreen;
    edit.aContact = self.contact;
    edit.recognizeID = 2333;
    edit.segmentSelect = self.superIndex;
    edit.frommessage2 = _fromfirendlist;
    
    
    [edit didContactEditedCallback:^(Contact *returnContact) {
        
        if(self.contact!=nil&&[returnContact.IMNumber isEqualToString:self.contact.IMNumber]){
            returnContact.stateText = self.contact.stateText;
        }else{
            returnContact.stateText = @"Offline";
        }
        self.contact = returnContact;
        if (self.contact.teststr) {
            self.imblock(self.contact.teststr);
        }
    }];
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:edit];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (IBAction)callOptionsAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    if (superControllerID != 7 && _dataSource.count >1) {
        currentButtonIndex = btn.tag;
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Numbers" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        sheet.tag = 101;
        for (id result in _dataSource) {
            if ([result isKindOfClass:[NgnPhoneNumber class]]) {
                NgnPhoneNumber *ngNumber = (NgnPhoneNumber *)result;
                [sheet addButtonWithTitle:ngNumber.number];
            }
            else if([result isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)result;
                NSString *key = [dic allKeys][0];
                [sheet addButtonWithTitle:dic[key]];
            }
        }
        [sheet showInView:self.navigationController.view];
    } else {
        NSString* tempzero = @"";
        
        if (_dataSource.count==1) {
            if ([_dataSource[0] isKindOfClass:[NgnPhoneNumber class]]) {
                
                NgnPhoneNumber *ngNumber = (NgnPhoneNumber *)_dataSource[0];
                tempzero = ngNumber.number;
                
            }else
            {
                NSDictionary* dic = _dataSource[0];
                NSString *key = [dic allKeys][0];
                
                tempzero = dic[key];
            }
        }
        
        if (btn.tag == 100) {
            NSString *localParty = [shareAppDelegate getShortRemoteParty:shareAppDelegate.account.LocalUri andCallee:nil];
            if (_dataSource.count==1) {
                chatView.chatSession = [databaseManage getChatSession:localParty RemoteUri:tempzero DisplayName:self.contact.displayName ContactId:self.contact.contdentifier];
            }
            else
            {
                chatView.chatSession = [databaseManage getChatSession:localParty RemoteUri:self.callHistory.mRemoteParty DisplayName:self.contact.displayName ContactId:self.contact.contdentifier];
            }
            
            // Pass the selected object to the new view controller.
            if(superControllerID == 3)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                if (_frommessagebutton) {
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
                
                [chatView hideTableViewHeaderView];
                
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatView animated:YES];
            }
        }
        else if (btn.tag == 101) {
            
            if (_frommessagebutton) {
                
                [[AppDelegate sharedInstance] makeCall:_partystr videoCall:NO];
            }
            else
            {
                
                if (_dataSource.count==1) {
                    
                    [[AppDelegate sharedInstance] makeCall:tempzero videoCall:NO];
                }
                
            }
            
        }
        else if (btn.tag == 102) {
            
            if (_frommessagebutton) {
                
                [[AppDelegate sharedInstance] makeCall:_partystr videoCall:YES];
            }else
            {
                
                if (_dataSource.count==1) {
                    
                    [[AppDelegate sharedInstance] makeCall:tempzero videoCall:YES];
                }
            }
            
        }
    }
    
}

#pragma  mark -favoraiteButtonClick
- (void)favoraiteButtonClick:(id)sender {
    
    if (self.contact.contdentifier==nil) {
        [self editContact:nil];
        return;
    }
    
    
    Favorite* favorite = nil;
    if (self.contact.phoneNumbers.count > 0) {
        NgnPhoneNumber* number = [self.contact.phoneNumbers objectAtIndex:0];
        
#ifdef __IPHONE_9_0
        favorite = [[Favorite alloc] initWithIdentifi:self.contact.contdentifier type:number.type typedescription:number.description num:number.number dispalyname:self.contact.displayName];
#else
        favorite = [[Favorite alloc] initWithID:self.contact.contactId type:number.type typedescription:number.description num:number.number dispalyname:self.contact.displayName];
#endif
        
    } else {
        if (self.contact.IPCallNumbers.count == 0)
            
            return;
        
        NSDictionary *dic = self.contact.IPCallNumbers[0];
        NSString *key = [dic allKeys][0];
        NSString *value = dic[key];
        
#ifdef __IPHONE_9_0
        favorite = [[Favorite alloc] initWithIdentifi:self.contact.contdentifier type:NgnPhoneNumberType_IPCall typedescription:NSLocalizedString(@"VoIP Call", @"VoIP Call") num:value dispalyname:self.contact.displayName];
#else
        favorite = [[Favorite alloc] initWithID:self.contact.contactId type:NgnPhoneNumberType_IPCall typedescription:NSLocalizedString(@"VoIP Call", @"VoIP Call") num:value dispalyname:self.contact.displayName];
#endif
        
    }
    
    if([databaseManage insertFavorite:favorite]) {
    }
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return ;
    }
    
    if (actionSheet.tag == 100) {
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
                self.contact.picture = nil;
                
                [self refreshUI];
                
                [self saveimage:nil];
                
                [[AppDelegate sharedInstance].recentsViewController RefreshRecntCon];
                break;
                
        }
    }
    if (actionSheet.tag == 101) {
        if ([_dataSource[buttonIndex - 1] isKindOfClass:[NgnPhoneNumber class]]) {
            NgnPhoneNumber *ngNumber = (NgnPhoneNumber *)_dataSource[buttonIndex-1];
            NSString *num = ngNumber.number;
            if (currentButtonIndex == 100) {
                NSString *localParty = [shareAppDelegate getShortRemoteParty:shareAppDelegate.account.LocalUri andCallee:nil];
                chatView.chatSession = [databaseManage getChatSession:localParty RemoteUri:num DisplayName:self.contact.displayName ContactId:self.contact.contdentifier];
                // Pass the selected object to the new view controller.
                if(superControllerID == 3)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    if (_frommessagebutton) {
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        return;
                    }
                    
                    [chatView hideTableViewHeaderView];
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:chatView animated:YES];
                }
            }
            else if (currentButtonIndex == 101) {
                [[AppDelegate sharedInstance] makeCall:num videoCall:NO];
            }
            else if (currentButtonIndex == 102) {
                [[AppDelegate sharedInstance] makeCall:num videoCall:YES];
            }
            
        } else if ([_dataSource[buttonIndex - 1] isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = _dataSource[buttonIndex - 1];
            NSString *key = [dic allKeys][0];
            if (currentButtonIndex == 100) { //message
                chatView.chatSession = chatView.chatSession = [databaseManage getChatSession:shareAppDelegate.account.LocalUri RemoteUri:dic[key] DisplayName:self.contact.displayName ContactId:self.contact.contdentifier];
                // Pass the selected object to the new view controller.
                if(superControllerID == 3)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    if (_frommessagebutton) {
                        [self.navigationController popViewControllerAnimated:YES];
                        return;
                    }
                    [chatView hideTableViewHeaderView];
                    
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:chatView animated:YES];
                    
                    //   self.hidesBottomBarWhenPushed = NO;
                }
            }
            else if (currentButtonIndex == 101) { //audioCall
                [[AppDelegate sharedInstance] makeCall:dic[key] videoCall:NO];
            }
            else if (currentButtonIndex == 102) { //videoCall
                [[AppDelegate sharedInstance] makeCall:dic[key] videoCall:YES];
            }
        }
    }
}



-(void)saveimage:(NSData*)imageData{
    
#ifdef __IPHONE_9_0
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:@[self.contact.contdentifier]];
    
    NSArray *contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactImageDataAvailableKey,CNContactImageDataKey] error:nil];
    if (contacts.count > 0) {
        CNMutableContact *cnContact = [contacts[0] mutableCopy];
        cnContact.imageData = imageData;
        
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
        [saveRequest updateContact:cnContact];
        [contactStore executeSaveRequest:saveRequest error:nil];
    }
    
#else
    ABAddressBookRef address = ABAddressBookCreate();
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(address, self.contact.contactId);
    ABPersonSetImageData(person, (__bridge CFDataRef)(imageData), NULL);
    
    ABAddressBookSave(address, NULL);
#endif
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (image) {
        textImage.hidden = YES;
        self.imageViewAvatar.hidden = NO;
        self.imageViewAvatar.image = image;
        headerImage = image;
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0);
        
        self.contact.picture = imageData;
        
        
#ifdef __IPHONE_9_0
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:@[self.contact.contdentifier]];
        
        NSArray *contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactImageDataAvailableKey,CNContactImageDataKey] error:nil];
        if (contacts.count > 0) {
            CNMutableContact *cnContact = [contacts[0] mutableCopy];
            cnContact.imageData = imageData;
            
            CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
            [saveRequest updateContact:cnContact];
            // 重新写入
            //                CNContactStore *store = [[CNContactStore alloc] init];
            [contactStore executeSaveRequest:saveRequest error:nil];
        }
        
#else
        ABAddressBookRef address = ABAddressBookCreate();
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(address, self.contact.contactId);
        ABPersonSetImageData(person, (__bridge CFDataRef)(imageData), NULL);
        
        ABAddressBookSave(address, NULL);
#endif
        
    }
    [[AppDelegate sharedInstance].recentsViewController RefreshRecntCon];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) { // 隐藏编辑图片时的导航栏
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.historyDitailTable) {
        return [_historyDic allKeys].count;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.historyDitailTable) {
        return 28.0;
    }
    
    CGFloat hi = (35*historyCount) + (28 * [_historyDic allKeys].count) ;
    
    return hi;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.historyDitailTable) {
        NSString *key = [_historyDic allKeys][section];
        UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.historyDitailTable.bounds.size.width, 28)];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 28)];
        
        headerLabel.text= key;
        headerLabel.textColor = [UIColor darkGrayColor];
        headerLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        
        [sectionHeader addSubview:headerLabel];
        return sectionHeader;
        
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.historyDitailTable) {
        NSString *key = [_historyDic allKeys][section];
        NSArray *arr = _historyDic[key];
        return arr.count;
    }
    
    
    NSUInteger count = [_dataSource count];
    return count + 8;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyDitailTable) {
        return 35;
    }
    
    if (self.contact.contdentifier==nil) {
        
        if (indexPath.row >=  _dataSource.count) {
            
            if (indexPath.row ==_dataSource.count +6 || indexPath.row ==_dataSource.count +7 ) {
                return 60;
            }
            return 0;
        }
        
    }
    else
    {
        
        if (indexPath.row ==_dataSource.count +5) {
            if (self.contact.IMNumber ==nil) {
                return 0;
            }
        }
        
        if (indexPath.row ==_dataSource.count +7) {
            return 0;
        }
        return 60;
    }
    
    return 60;
}

-(void)customCellwithoriginCell:(UITableViewCell *)cell title:(NSString *)str subtitle:(NSString *)sub{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 100, 20)];
    titleLabel.text = str;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor darkGrayColor];
    [cell.contentView addSubview:titleLabel];
    
    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 33, 200, 20)];
    if (sub) {
        subtitle.text = sub;
    }
    subtitle.textColor = [UIColor darkGrayColor];
    subtitle.font = [UIFont systemFontOfSize:17];
    [cell.contentView addSubview:subtitle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyDitailTable) {
        HistoryDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:HistoryDeatailIdenti];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"HistoryDetailCell" owner:self options:nil][0];
        }
        NSString *key = [_historyDic allKeys][indexPath.section];
        NSArray *value = _historyDic[key];
        
        History *history = [[[value reverseObjectEnumerator] allObjects] objectAtIndex:indexPath.row];
        
        [cell setHistoryDetailCellwith:history];
        
        return cell;
    }
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (self.contact.contdentifier==nil){
        
        if (indexPath.row >= _dataSource.count) {
            
            cell.hidden  = YES;
        }
    }
    
    if (indexPath.row == _dataSource.count) {
        
        [self customCellwithoriginCell:cell title:NSLocalizedString(@"FirstName", @"FirstName") subtitle:self.contact.firstName];
        
        return cell;
    }
    
    else if (indexPath.row == _dataSource.count + 1) {
        
        [self customCellwithoriginCell:cell title:NSLocalizedString(@"LastName", @"LastName") subtitle:self.contact.lastName];
        return cell;
    }
    
    if (self.superControllerID != 7) {
        
        if (indexPath.row == _dataSource.count + 2) {
            
            [self customCellwithoriginCell:cell title:NSLocalizedString(@"Company", @"Company") subtitle:self.contact.company];
            return cell;
        }
        else if (indexPath.row == _dataSource.count + 3) {
            
            [self customCellwithoriginCell:cell title:NSLocalizedString(@"Department", @"Department") subtitle:self.contact.partment];
            return cell;
        }
        else if (indexPath.row == _dataSource.count + 4) {
            
            [self customCellwithoriginCell:cell title:NSLocalizedString(@"JobTitle", @"JobTitle") subtitle:self.contact.jobtitle];
            return cell;
        }
        
        else if (indexPath.row == _dataSource.count +5 ) {
            if (self.contact.IMNumber ==nil) {
                cell.hidden = YES;
                
            }
            [self customCellwithoriginCell:cell title:NSLocalizedString(@"IM", @"IM") subtitle:self.contact.IMNumber];
            
            return cell;
        }
        
        else if (indexPath.row == _dataSource.count + 6) {
            
            cell.hidden = NO;
            
            
            return [self addToFavoriteCell];
            
        }
        
        else if (indexPath.row == _dataSource.count + 7) {
            
            if (self.contact.contdentifier==nil) {
                cell.hidden = NO;
            }
            else
            {
                cell.hidden = YES;
                
            }
            return [self addToexistingContact];
            
        }
        
    } else {
        if (!_contactExist) {
            if (indexPath.row == _dataSource.count + 2) {
                
                cell.textLabel.text = NSLocalizedString(@"Create New Contact", @"Create New Contact");
                cell.textLabel.textColor = [UIColor darkGrayColor];
                return cell;
            }
            else if (indexPath.row == _dataSource.count + 3) {
                cell.textLabel.text = NSLocalizedString(@"Add to Existing Contact", @"Add to Existing Contact");
                cell.textLabel.textColor = [UIColor darkGrayColor];
                return cell;
            }
        }
        if (indexPath.row == (_contactExist == YES ? _dataSource.count + 3 : _dataSource.count + 5)) {
            
            return [self addToFavoriteCell];
        }
        
    }
    
    static NSString *cellID = @"reuseID";
    ContactDetailViewCell *detailCell = (ContactDetailViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!detailCell) {
        detailCell = [[NSBundle mainBundle] loadNibNamed:@"ContactDetailViewCell" owner:self options:nil][0];
    }
    if (_dataSource.count > 0) {
        
        NSString *numbe = nil;
        NSString *phoneType = nil;
        
        if ([_dataSource[indexPath.row] isKindOfClass:[NgnPhoneNumber class]]) {
            NgnPhoneNumber *ngNumber = (NgnPhoneNumber *)[_dataSource objectAtIndex:indexPath.row];
            numbe = ngNumber.number;
            phoneType = ngNumber.description;
        }
        
        else if ([_dataSource[indexPath.row] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)[_dataSource objectAtIndex:indexPath.row];
            NSString *key = [dic allKeys][0];
            numbe = dic[key];
            phoneType = key;
        }
        
        //        NSString *phoneStr = [NSString stringWithFormat:@"%@\n%@",numbe, phoneType == nil ? NSLocalizedString(@"Unknown", @"Unknown") : phoneType];
        
        NSString *phoneStr = [NSString stringWithFormat:@"%@\n%@", phoneType == nil ? NSLocalizedString(@"Unknown", @"Unknown") : phoneType,numbe];
        detailCell.phoneNumberNType.text = phoneStr;
        
        [detailCell didButtonClickedCallback:^(id sender) {
            UIButton *btn = (UIButton *)sender;
            if (btn.tag == 100) {
                [[AppDelegate sharedInstance] makeCall:numbe videoCall:NO];
            }
            else if (btn.tag == 101) {
                [[AppDelegate sharedInstance] makeCall:numbe videoCall:YES];
            }
            else {
                NSString *localParty = [shareAppDelegate getShortRemoteParty:shareAppDelegate.account.LocalUri andCallee:nil];
                chatView.chatSession = [databaseManage getChatSession:localParty RemoteUri:numbe DisplayName:self.contact.displayName ContactId:self.contact.contdentifier];
                
                // Pass the selected object to the new view controller.
                if(superControllerID == 3)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    
                    if (_frommessagebutton) {
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        return;
                        
                    }
                    self.hidesBottomBarWhenPushed = YES;
                    [chatView hideTableViewHeaderView];
                    [self.navigationController pushViewController:chatView animated:YES];
                    
                    //   self.hidesBottomBarWhenPushed = NO                    ;
                }
            }
        }];
    }
    return detailCell;
}


-(void)addToexistingContactbuttonclick{
    
    NSLog(@"addToexistingContact");
    
    NSDictionary * dic;
    
    for (NgnPhoneNumber *number in contact.phoneNumbers){
        
        if ([number.number containsString:@"@"]){
            
            dic = [NSDictionary dictionaryWithObject:number.number forKey:NSLocalizedString(@"VoIP Call", @"VoIP Call")];
            
            
            
        }
        
    }
    
    NSLog(@"add0 dic =====%@",dic);
    
    AddToExistingContactTableViewController * addcon = [[AddToExistingContactTableViewController alloc]initWithStyle:0];
    
    addcon.addvoidcall0 = dic;
    
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addcon animated:YES];
}

-(UITableViewCell *)addToexistingContact{
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    favorateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favorateButton.frame = CGRectMake(cell.bounds.size.width - 45, 15, 30, 30);
    
    if (self.contact.contdentifier==nil) {
        
        cell.textLabel.text = NSLocalizedString(@"Add to Existing Contact",@"Add to Existing Contact");
        
        [favorateButton setImage:nil forState:UIControlStateNormal];
    }
    
    [cell.contentView addSubview:favorateButton];
    return cell;
}



-(UITableViewCell *)addToFavoriteCell {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    favorateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    favorateButton.frame = CGRectMake(ScreenWid-45, 15, 30, 30);
    
    BOOL favoraited = NO;
    for (Favorite *value in [self myFavoraites]) {
#ifdef __IPHONE_9_0
        if ([value.mFavoriteIdentifi isEqualToString:self.contact.contdentifier]) {
            favoraited = YES;
        }
#else
        if (value.mFavoriteId == self.contact.contactId) {
            favoraited = YES;
        }
#endif
        
    }
    if (favoraited) {
        cell.textLabel.text = NSLocalizedString(@"Remove from Favorite", @"Remove from Favorite");
        [favorateButton setImage:[UIImage imageNamed:@"contact_bookmarks_ico_pre"] forState:UIControlStateNormal];
        cell.tag = 100;
    } else {
        cell.textLabel.text = NSLocalizedString(@"Add to Favorite", @"Add to Favorite");
        [favorateButton setImage:[UIImage imageNamed:@"contact_bookmarks_ico_def"] forState:UIControlStateNormal];
        cell.tag = 101;
    }
    
    if (self.contact.contdentifier==nil) {
        
        cell.textLabel.text = NSLocalizedString(@"Create New Contact", @"Create New Contact");
        
        [favorateButton setImage:nil forState:UIControlStateNormal];
    }
    
    [favorateButton addTarget:self action:@selector(favoraiteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:favorateButton];
    return cell;
}

#pragma mark - Table view delegate

- (void)newPersonWithPhonenumber:(NSString*)number
{
    ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:npvc];
    CFErrorRef error =NULL;
    
    ABRecordRef personRef = ABPersonCreate();
    
    ABMutableMultiValueRef multi=ABMultiValueCreateMutable(kABMultiStringPropertyType);
    bool didAddIM = ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(number), kABOtherLabel, NULL);
    if(didAddIM){
        ABRecordSetValue(personRef, kABPersonEmailProperty, multi, &error);
    }
    CFRelease(multi);
    
    if(contact){
        ABRecordSetValue(personRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)contact.displayName, nil);
    }
    
    npvc.displayedPerson = personRef;
    
    npvc.newPersonViewDelegate = self;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    npvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.historyDitailTable) {
        return ;
    }
    
    if (self.superControllerID == 7) {
        if (!_contactExist) {
            if (indexPath.row == _dataSource.count + 2) {
                
                AddorEditViewController *ctr = [[AddorEditViewController alloc] init];
                ctr.modalPresentationStyle = UIModalPresentationFullScreen;
                ctr.recognizeID = 2666;
                ctr.numbPadenterString = self.callHistory.mRemoteParty;
                
                NSLog(@"self.callHistory.mRemoteParty======%@",self.callHistory.mRemoteParty);
                
                [ctr didAddHistoryToContactCallback:^{
                    _popBack = YES;
                }];
                
                UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:ctr];
                navc.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:navc animated:YES completion:^{
                    
                }];
                
            }
            else if (indexPath.row == _dataSource.count + 3) {
                ContactListViewController *contactList = [[ContactListViewController alloc] init];
                contactList.remoteParty = self.callHistory.mRemoteParty;
                
                self.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:contactList animated:YES];
                
                self.hidesBottomBarWhenPushed = NO;
            }
        }
        if (indexPath.row == (_contactExist == YES ? _dataSource.count + 2 : _dataSource.count + 4)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (cell.tag == 100) {
                for (Favorite *value in [self myFavoraites]) {
#ifdef __IPHONE_9_0
                    if ([value.mFavoriteIdentifi isEqualToString:self.contact.contdentifier]) {
                        [databaseManage removeFavorite:value];
                    }
#else
                    if (value.mFavoriteId == self.contact.contactId) {
                        [databaseManage removeFavorite:value];
                    }
#endif
                    
                }
            }
            if(cell.tag == 101) {
                [self favoraiteButtonClick:nil];
            }
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            return;
        }
    } else { //supercontrollerID != 7
        if (indexPath.row == _dataSource.count + 6) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (cell.tag == 100) {
                for (Favorite *value in [self myFavoraites]) {
                    if ([value.mFavoriteIdentifi isEqualToString:self.contact.contdentifier]) {
                        [databaseManage removeFavorite:value];
                    }
                }
            }
            if(cell.tag == 101) {
                [self favoraiteButtonClick:nil];
            }
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            return;
        }
        
        if (indexPath.row == _dataSource.count +7) {
            NSLog(@"phoneNumbers==1====%@",self.contact.phoneNumbers);
            [self addToexistingContactbuttonclick];
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
