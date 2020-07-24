//
//  MessagesViewController.m
//  PortGo
//
//  Created by Joe Lepple on 4/13/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "MessagesViewController.h"
#import "DataBaseManage.h"
#import "MessageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "UIColor_Hex.h"
#import "HSChatViewController.h"
#import "NSString+HSFilterString.h"
#import "NSString+HSFilterString.h"
#import "Masonry.h"
#import "AddFriendsTableViewController.h"

#import "JRDB.h"
#import "HttpHelper.h"
#import "addFriendModel.h"
//
//	Private
//

@interface MessagesViewController(Private)


-(void) refreshData;
-(void) refreshDataAndReload;
-(void) refreshView;
//-(void) onHistoryEvent:(NSNotification*)notification;
@end

@implementation MessagesViewController(Private)

-(void) refreshData{
    @synchronized(chatSessions){
        chatSessions = [databaseManage selectChatSessionByLocalUri:shareAppDelegate.account.LocalUri];
        [self refreshView];
    }
}

#pragma mark -
#pragma mark 删除默认消息
-(void)DeleteTheDefaultMessage{
    
    NSMutableArray * temparr = [[NSMutableArray alloc]init];
    //    selectSessions = [[NSMutableArray alloc]init];
    //
    //    for (History * temp in  messages) {
    //
    //        if(temp.mMediaType == MediaType_IMMsg){
    //            [defaulArr addObject:temp];
    //        }else
    //        {
    //            [temparr addObject:temp];
    //        }
    //    }
    //
    //    messages = temparr;
    
}

-(void)checkdefaulArr{
    //    NSMutableArray * temparr = [[NSMutableArray alloc]initWithArray:defaulArr];
    //
    //    //清除已存在的
    //    NSArray * allcontactarr = [contactView contacts];
    //
    //    for (Contact * con in  allcontactarr) {
    //
    //   //     NSLog(@"con.IMNumber=======%@",con.IMNumber);
    //        for (History *his in defaulArr){
    //            if ([his.mRemoteParty isEqualToString:con.IMNumber]) {
    //                [temparr removeObject:his];
    //            }
    //        }
    //    }
    //
    //
    //    defaulArr = temparr;
    //
    //    NSMutableArray * temp2 = [[NSMutableArray alloc]initWithArray:defaulArr];
    //    NSArray * addfirendarr =[addFriendModel jr_findAll];
    //
    //    for (addFriendModel *model in  addfirendarr) {
    //
    //        for (History * his in  defaulArr) {
    //            if ([his.mRemoteParty isEqualToString:model.mRemoteParty]) {
    //                [temp2 removeObject:his];
    //            }
    //        }
    //
    //    }
    //
    //    defaulArr =temp2;
    [self setaddnav];
}


-(void)setaddnav{
    
#pragma clang diagnostic push
    
#pragma clang diagnostic ignored"-Wundeclared-selector"
    
    self->navigationItemCompose = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_nav_ico_new_message_ico"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonNavivationItemClick:)];
    
    self.navigationItem.rightBarButtonItems = @[navigationItemCompose];
#pragma clang diagnostic pop
    
}


-(void) refreshDataAndReload{
    [self refreshData];
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 45)];
    
}

-(void) refreshView{
    //    joe alway use tableview
    self.view = self.tableView;
    if([chatSessions count] > 0){
        self.navigationItem.leftBarButtonItem = self.tableView.editing ? self->navigationItemDone : self->navigationItemEdit;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
@end

@interface MessagesViewController () <UISearchControllerDelegate, UISearchResultsUpdating>
{
    
    NSMutableArray *searchResult;
    NSMutableArray *deleteMessages;
    NSMutableArray *deleteIndexpaths;
    
    UIView *_bottomView;
    
    BOOL _hasNewRemote;
    
}

@property(strong, nonatomic) UISearchController *mSearchDisplay;
@end

@implementation MessagesViewController
//@synthesize buttonComposeMessage;
//@synthesize chatSessions;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initSearchBar {
    
    _mSearchDisplay = [[UISearchController alloc] initWithSearchResultsController:nil];
    _mSearchDisplay.searchResultsUpdater = self;
    _mSearchDisplay.delegate = self;
    _mSearchDisplay.dimsBackgroundDuringPresentation = false;
    _mSearchDisplay.definesPresentationContext = YES;
    
    self.tableView.sectionHeaderHeight = 30 ;
    [self.tableView setEditing:NO animated:YES];
    self.tableView.tableHeaderView = _mSearchDisplay.searchBar;
    self.tableView.tableFooterView = [UIView new];
    
    self.definesPresentationContext = YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if(@available(iOS 11.0, *)){
        
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(20,0, 0, 0); //IEdgeInsetsZero;
        [self.tableView layoutIfNeeded];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)changeNameRefresh{
    
    NSLog(@"changeNameRefresh");
    
    [self.tableView reloadData];
    
    
}

#pragma mark -
#pragma mark viewDidLoad

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor *bkColor,*bkColorLight;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
        bkColorLight = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColor = [UIColor whiteColor];
        bkColorLight = [UIColor lightGrayColor];
    }
    
    [self.navigationController.navigationBar setBackgroundColor:bkColor];
    [self.navigationController.navigationBar setBarTintColor:bkColor];
    [self.tabBarController.tabBar setBarTintColor:bkColor];
    
    UIView *tableBackgroundView = [[UIView alloc]initWithFrame:self.tableView.bounds];
    tableBackgroundView.backgroundColor = bkColor;
    self.tableView.backgroundView = tableBackgroundView;
    
    if (@available(iOS 13.0, *)) {
        _mSearchDisplay.searchBar.barTintColor = bkColor;//搜索框外框背景
        _mSearchDisplay.searchBar.searchTextField.backgroundColor = bkColorLight;//搜索框内框背景
    }
    [self refreshDataAndReload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeNameRefresh) name:@"changeNameRefresh" object:nil];
    
    
    
    
    self.title = NSLocalizedString(@"Messages", @"Messages");
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:MAIN_COLOR}];
    
    self.navigationController.navigationBar.tintColor = MAIN_COLOR;
    
    //    UIImage *colorImage = [UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)];
    
    
    [self.navigationController.navigationBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    
    
    
    [self.tabBarController.tabBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setBackgroundImage:[[UIImage alloc]init]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if(!chatSessions){
        chatSessions = [[NSMutableArray alloc] init];
    }
    
    
    self->navigationItemEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                             target:self
                                                                             action:@selector(onButtonNavivationItemClick:)];
    
    self->navigationItemDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(onButtonNavivationItemClick:)];
    self->navigationItemCompose = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_nav_ico_new_message_ico"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonNavivationItemClick:)];
    
    self->navigationItemSelectAll = [[UIBarButtonItem alloc] initWithTitle:
                                     NSLocalizedString(@"Select All", @"Select All") style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onButtonNavivationItemClick:)];
    
    self.navigationItem.rightBarButtonItems = @[navigationItemCompose];
    
    _mMessageFilter = MediaType_Message;
    
    [self refreshData];
    
    [self setaddnav];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    [self initSearchBar];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:kMessageCellIdentifier];
    
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.modalPresentationStyle = UIModalPresentationPageSheet;
    
    [self traitCollectionDidChange:self.traitCollection];
}

-(void)countBrage{
    [shareAppDelegate refreshItemBadge];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshDataAndReload];
    
    [self checkdefaulArr];
    
    //   NSLog(@"messages.count======%d",messages.count);
    [self countBrage];
    [UIApplication sharedApplication].statusBarStyle = 0;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationItem.leftBarButtonItem == self->navigationItemDone) {
        [self onButtonNavivationItemClick:self->navigationItemDone];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [chatSessions removeAllObjects];
}


#pragma mark
-(void)AddFriends{
    AddFriendsTableViewController *addcon   = [[AddFriendsTableViewController alloc]init];
    
    //    addcon.AddFriendsArr = defaulArr;
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addcon animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (IBAction) messageSegmentClicked: (id)sender
{
    NSInteger index = [sender selectedSegmentIndex];
    
    switch (index) {
        case 0://IM
            _mMessageFilter = MediaType_Chat;
            [self refreshDataAndReload];
            break;
        case 1://SMS
            _mMessageFilter = MediaType_SMS;
            [self refreshDataAndReload];
            break;
        default:
            break;
    }
}


-(UIView *)createBottomView {
    CGFloat viewHeight = self.navigationController.view.bounds.size.height;
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 49 - 44 -30, self.tableView.bounds.size.width, 44)];
    bottom.backgroundColor = [UIColor colorWithRed:229.0/255 green:230.0/255 blue:231.0/255 alpha:1];
    
    UIButton *markRead = [UIButton buttonWithType:UIButtonTypeSystem];
    markRead.frame = CGRectMake(20, 5, 80, 30);
    [markRead setTitle:NSLocalizedString(@"All read", @"All read") forState:UIControlStateNormal];
    
    
    
    [markRead setTitleColor:[UIColor colorWithRed:75.0/255 green:185.0/255 blue:237.0/255 alpha:1] forState:UIControlStateNormal];
    markRead.tag = 100;
    [markRead addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:markRead];
    
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeSystem];
    delete.frame = CGRectMake(bottom.bounds.size.width - 50, 5, 50, 30);
    [delete setTitle:NSLocalizedString(@"Delete", @"Delete") forState:UIControlStateNormal];
    [delete setTitleColor:[UIColor colorWithRed:75.0/255 green:185.0/255 blue:237.0/255 alpha:1] forState:UIControlStateNormal];
    delete.tag = 101;
    [delete addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:delete];
    
    return bottom;
}


-(void)bottomButtonAction:(UIButton *)sender {
    if (sender.tag == 100) {
        //标记为已读
        for (HSChatSession *value in chatSessions) {
            [databaseManage updateMessageReadStatusBySession:value.mRowid HasRead:true];
        }
        
        [self countBrage];
        
        [self refreshView];
        [self.tableView reloadData];
        
        
    } else {
        
        for (HSChatSession *deletValue in deleteMessages) {
            [databaseManage deleteChatSessionBySessionId:deletValue.mRowid];
            [databaseManage updateSessionUnreadCount:deletValue.mRowid UnreadCount:0];
            [databaseManage updateMessageReadStatusBySession:deletValue.mRowid HasRead:true];
            [chatSessions removeObject:deletValue];
            
        }
        
        [self countBrage];
        
        [self.tableView deleteRowsAtIndexPaths:deleteIndexpaths withRowAnimation:UITableViewRowAnimationTop];
        [self onButtonNavivationItemClick:self->navigationItemDone];
        
        [self refreshView];
        
    }
}

- (IBAction) onButtonNavivationItemClick: (id)sender{
    if(sender == self->navigationItemCompose){
        [self onButtonComposeClick:sender];
    }
    else if(sender == self->navigationItemEdit || sender == self->navigationItemDone) {
        if(sender == self->navigationItemEdit){
            self.tableView.tableHeaderView = nil;
        }else{
            self.tableView.tableHeaderView = _mSearchDisplay.searchBar;
        }
        [deleteIndexpaths removeAllObjects];
        [deleteMessages removeAllObjects];
        
        if((self.tableView.editing = !self.tableView.editing)){
            self.navigationItem.leftBarButtonItem = self->navigationItemDone;
            self.navigationItem.rightBarButtonItem = self->navigationItemSelectAll;
            if (!deleteMessages) {
                deleteMessages = [NSMutableArray array];
            }
            if (!deleteIndexpaths) {
                deleteIndexpaths = [NSMutableArray array];
            }
            if (!_bottomView) {
                _bottomView = [self createBottomView];
            }
            [self.navigationController.view addSubview:_bottomView];
        }
        else {
            self.navigationItem.leftBarButtonItem = self->navigationItemEdit;
            //   self.navigationItem.rightBarButtonItem = self->navigationItemCompose;
            
            [self setaddnav];
            
            [_bottomView removeFromSuperview];
            if (deleteMessages.count > 0) {
                [deleteMessages removeAllObjects];
            }
            deleteMessages = nil;
            if (deleteIndexpaths.count > 0) {
                [deleteIndexpaths removeAllObjects];
            }
            deleteIndexpaths = nil;
        }
    }
    else if (sender == self->navigationItemSelectAll) {
        [deleteMessages removeAllObjects];
        [deleteIndexpaths removeAllObjects];
        
        for (int i = 0; i < chatSessions.count; i ++) {
            HSChatSession *session = chatSessions[i];
            [deleteMessages addObject:session];
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            [deleteIndexpaths addObject:index];
            [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
}



-(void)loginoutEmptyHistory{
    
    NSLog(@"loginoutEmptyHistory");
    
    //    for (History *deletValue in messages) {
    //
    //        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    //        Options *options = [databaseManage mOptions];
    //        options.mMsgBadge = 0;
    //
    //        [user setInteger:0 forKey:deletValue.mRemoteParty];
    //        [user synchronize];
    
    //        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //
    //        [databaseManage saveOptions];
    //        [shareAppDelegate refreshItemBadge];
    //
    //        [databaseManage deleteAllHistory:_mMessageFilter withRemoteParty:[deletValue mRemoteParty]];
    //        [messages removeObject:deletValue];
    //
    //    }
}


#pragma mark -
#pragma mark 右上角发送新消息

- (IBAction) onButtonComposeClick: (id)sender{
    chatView.chatSession=nil;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRecvOutOfDialogMessage:(long)messageId
                 fromDisplayName:(NSString*)fromDisplayName
                            from:(NSString*)from
                        mimeType:(NSString*)mimeType
                     subMimeType:(NSString*)subMimeType
                     messageData:(NSString*)messageData
                     messageTime:(long)messageTime
{
    NSTimeInterval recvTime = [[NSDate date] timeIntervalSince1970];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [self refreshDataAndReload];
    [self countBrage];
    
    if(_mSearchDisplay.active){
        NSString* textBack = _mSearchDisplay.searchBar.text;
        _mSearchDisplay.searchBar.text = @"";
        _mSearchDisplay.searchBar.text = textBack;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"loadmessage" object:nil];
}

- (void)onPresenceRecvSubscribe:(long)subscribeId
                fromDisplayName:(NSString *)fromDisplayName
                           from:(NSString *)from
                        subject:(NSString *)subject
{
    NSLog(@"onPresenceRecvSubscribe==onPresenceRecvSubscribe");
    return;
    Options *options = [databaseManage mOptions];
    options.mMsgBadge++;
    [databaseManage saveOptions];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification* localNotif = [[UILocalNotification alloc] init];
        NSString *nickName = fromDisplayName;
        
        localNotif.alertBody = [NSString stringWithFormat:@"%@:%@", nickName, subject];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        
        localNotif.repeatInterval = 0;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"imsg", @"key",nil];
        localNotif.userInfo = userInfo;
        [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
    } else {
        [shareAppDelegate refreshItemBadge];
    }
    
    NSTimeInterval recvTime = [[NSDate date] timeIntervalSince1970];
    History *history = [[History alloc] initWithName:0
                                       byRemoteParty:from
                                       byDisplayName:fromDisplayName
                                        byLocalParty:shareAppDelegate.account.userName
                                  byLocalDisplayname:shareAppDelegate.account.accountName
                                         byTimeStart:recvTime byTimeStop:recvTime
                                          byMediaype:MediaType_IMMsg
                                        byCallStatus:(int)subscribeId
                                           byContent:[subject dataUsingEncoding:NSUTF8StringEncoding]];
    
    [databaseManage insertHistory:history];
    
    [self refreshDataAndReload];
    
    if([chatView checkRemoteParty:from])
    {
        [chatView refreshDataAndReload];
    }
    
}

- (void)onSendOutOfDialogMessageSuccess:(long)messageId
                        fromDisplayName:(char*)fromDisplayName
                                   from:(char*)from
                          toDisplayName:(char*)toDisplayName
                                     to:(char*)to;
{
    NSLog(@"chat message onSendOutOfDialogMessageSuccess Id= %ld", messageId);
    [databaseManage updateChatHistoryStatusByMessageid:messageId withStatus:OUTGOING_SUCESS];//
    [chatView refreshDataAndReload];
    
    if(_mSearchDisplay.active){
        NSString* textBack = _mSearchDisplay.searchBar.text;
        _mSearchDisplay.searchBar.text = @"";
        _mSearchDisplay.searchBar.text = textBack;
    }
    
}

- (void)onSendOutOfDialogMessageFailure:(long)messageId
                        fromDisplayName:(char*)fromDisplayName
                                   from:(char*)from
                          toDisplayName:(char*)toDisplayName
                                     to:(char*)to
                                 reason:(char*)reason
                                   code:(int)code;
{
    
    if(code == 480){
        [databaseManage updateChatHistoryStatusByMessageid:messageId withStatus:OUTGOING_SUCESS];//
    }else{
        [databaseManage updateChatHistoryStatusByMessageid:messageId withStatus:OUTGOING_FAILED];//成功
    }
    NSLog(@"chat message onSendOutOfDialogMessageFailure Id= %ld", messageId);
    [chatView refreshDataAndReload];
    if(_mSearchDisplay.active){
        NSString* textBack = _mSearchDisplay.searchBar.text;
        _mSearchDisplay.searchBar.text = @"";
        _mSearchDisplay.searchBar.text = textBack;
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    return 51.0f;
    return 75.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (_mSearchDisplay.active) {
        return searchResult.count;
    }
    
    @synchronized(chatSessions){
        return [chatSessions count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier: kMessageCellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil][0];
    }
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //  NSLog(@"inte======%d",inte);
    
    
    if (_mSearchDisplay.active) {
        [cell setChatHistory:[searchResult objectAtIndex:indexPath.row]];
    }else{
        HSChatSession *session = [chatSessions objectAtIndex:indexPath.row];
        if (session.mCount<= 0) {
            cell.countLabel.hidden = YES;
        } else {
            cell.countLabel.hidden = NO;
            cell.countLabel.text = [NSString stringWithFormat:@"%ld",(long)session.mCount];
        }
        
        cell.countLabel.tag = 302+indexPath.row;
        
        cell.RedDelegate = ^(NSInteger tag) {
            [self  dismissRedNum:tag];
        };
        [cell setChatSession:[chatSessions objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

-(void)dismissRedNum:(NSInteger)tag{
    
    Options *options = [databaseManage mOptions];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = options.mCallBadge + options.mMsgBadge;
    [databaseManage saveOptions];
    [shareAppDelegate refreshItemBadge];
}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return _mSearchDisplay.searchBar;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 45;
//
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mSearchDisplay.active) {
        if (searchResult.count > indexPath.section) {
            History* history = [searchResult objectAtIndex:indexPath.row];
            chatView.chatSession =[databaseManage findChatSessionById:history.mSessionId];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatView animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            //[_mSearchDisplay dismissViewControllerAnimated:false completion:nil];
        }
    } else {
        if (self.tableView.isEditing) {
            HSChatSession *deleteSession = chatSessions[indexPath.row];
            [deleteMessages addObject:deleteSession];
            [deleteIndexpaths addObject:indexPath];
        } else {
            if([chatSessions count] > indexPath.section){
                HSChatSession* session = [chatSessions objectAtIndex:indexPath.row];
                chatView.chatSession = session;
                
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatView animated:YES];
                self.hidesBottomBarWhenPushed = NO;
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        HSChatSession *delSession = chatSessions[indexPath.row];
        for (int i = 0; i < deleteMessages.count; i ++) {
            HSChatSession *value = deleteMessages[i];
            if (value.mRowid == delSession.mRowid) {
                [deleteMessages removeObjectAtIndex:i];
                [deleteIndexpaths removeObject:indexPath];
            }
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSInteger tempindex = indexPath.row;
    
    if (tempindex>=chatSessions.count) {
        tempindex = chatSessions.count-1;
    }
    
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Delete",@"Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        HSChatSession* session = [chatSessions objectAtIndex: tempindex];
        if (session) {
            [self countBrage];
            [databaseManage deleteChatSessionBySessionId:session.mRowid];
            [databaseManage updateMessageReadStatusBySession:session.mRowid HasRead:true];
        }
        [chatSessions removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    deleteAction.backgroundColor = RGB(219, 0, 0);
    
    
    
    UITableViewRowAction *vedioCallAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Video Call",@"Video Call") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        HSChatSession* session = [chatSessions objectAtIndex:indexPath.row];
        [shareAppDelegate makeCall:session.mRemoteUri videoCall:YES];
        
    }];
    
    vedioCallAction.backgroundColor = RGB(107 , 184, 129);
    
    
    UITableViewRowAction *audioCallAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Audio Call",@"Audio Call") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        HSChatSession* session = [chatSessions objectAtIndex:indexPath.row];
        [shareAppDelegate makeCall:session.mRemoteUri videoCall:NO];
    }];
    
    audioCallAction.backgroundColor = RGB(100, 170, 236);
    
    
    return @[deleteAction,vedioCallAction,audioCallAction];
}


#pragma mark - UISearchControllerMethod
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [searchResult removeAllObjects];
    NSString* searchString = _mSearchDisplay.searchBar.text;
    searchResult = [NSMutableArray array];
    
    if (searchString == nil || [searchString isEqual:@""]) {
        //[searchResult addObjectsFromArray:chatSessions];
    }else{
        NSMutableArray* sessions = [[NSMutableArray alloc] init];
        for (HSChatSession *value in chatSessions) {
            [sessions addObject:[NSNumber numberWithLong:value.mRowid]];
        }
        NSMutableArray* messages =[databaseManage searchMessage:searchString byMediaType:MediaType_Chat Sessions:sessions orderBYDESC:YES];
        for (History *history in messages) {
            [searchResult addObject:history];
        }
    }
    
    [self.tableView reloadData];
}

@end
