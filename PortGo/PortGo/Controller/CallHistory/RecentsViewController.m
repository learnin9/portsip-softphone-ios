//
//  RecentsViewController.m
//  PortGo
//
//  Created by Joe Lepple on 3/26/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "RecentsViewController.h"
#import "DataBaseManage.h"
#import "AppDelegate.h"
#import "HSRecentCell.h"
#import "History.h"
#import "UIColor_Hex.h"
#import "ContactDetailsViewController.h"

#import "MJRefresh.h"

#define cellID @"HSRecentCellID"
@interface RecentsViewController (Private)


-(void) refreshData;
-(void) refreshDataAndReload;
@end

@implementation RecentsViewController(Private)



-(void) refreshData{
	@synchronized(mHistoryArray){
		[mHistoryArray removeAllObjects];
        mHistoryArray = [[NSMutableArray alloc] init];
        
        NSMutableArray *historyArray = [databaseManage selectHistory:0 byMediaType:MediaType_AudioVideo  LocalUri:AppDelegate.sharedInstance.account.userName orderBYDESC:YES needCount:NO];
        
        int count = 1;
        History *lastHistory = nil;
        for (int i = 0; i < historyArray.count; i ++) {
            History *currentHistory = historyArray[i];
            if(!currentHistory || !([currentHistory mMediaType] & MediaType_AudioVideo) || (mStatusFilter!=HistoryEventStatus_All&&!IS_EVENT_INCOMING_FAILED([currentHistory mStatus]))){
                //Skip message history
                continue;
            }
            
            if(lastHistory == nil){
                lastHistory = currentHistory;
                count = 1;
                continue;
            }
            else{
                if (lastHistory.mMediaType == currentHistory.mMediaType &&
                    [lastHistory.mRemoteParty isEqualToString:currentHistory.mRemoteParty] &&
                    lastHistory.mStatus == currentHistory.mStatus) {
                    //Merge display
                    count++;
                } else {
                    //add new history to display array
                    lastHistory.historyCount = count;
                    [mHistoryArray addObject:lastHistory];
                    lastHistory = currentHistory;
                    count = 1;
                }
                
            }
        }
        
        if(lastHistory != nil)
        {//Add last history
            lastHistory.historyCount = count;
            [mHistoryArray addObject:lastHistory];
        }
	}
    
   // NSLog(@"mHistoryArray=====%@",mHistoryArray);

    
    showindex  =10;
    
    if (showindex >mHistoryArray.count) {
        
        showindex = mHistoryArray.count;
        
    }
    
    [self.tableView.mj_footer endRefreshing];
    

    
//    if (lastListCount ==0) {
//             [[self tableView] reloadData];
//    }
    
    
    if (lastListCount !=  mHistoryArray.count ) {
        
        [[self tableView] reloadData];
        
       // NSLog(@"lastListCount%d  mHistoryArray.count=%d ",lastListCount,mHistoryArray.count);
    }
    
    
      lastListCount = mHistoryArray.count;
    
  
    
}

-(void)refreshDataAndReload{
	[self refreshData];
    

}




@end

@implementation RecentsViewController


-(void)RefreshRecntCon{
    
    [[self tableView] reloadData];

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
         
    }
    return self;
}

-(NSArray *)getHistorys {
    if (!mHistoryArray || mHistoryArray.count == 0) {
        mStatusFilter = HistoryEventStatus_All;
        [self refreshData];
    }
    return mHistoryArray;
}


#pragma mark - viewDidLoad
#pragma mark 最近通话

-(void)viewWillAppear:(BOOL)animated
{
        [UIApplication sharedApplication].statusBarStyle = 0;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor colorWithHexString:@"#f4f3f3"];
    }
    
    [self.navigationController.navigationBar setBackgroundColor:bkColor];
    [self.navigationController.navigationBar setBarTintColor:bkColor];
    [self.tabBarController.tabBar setBarTintColor:bkColor];
    self.tableView.backgroundColor = bkColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

  
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //joe temp self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.segment setTitle:NSLocalizedString(@"All Calls", @"All Calls") forSegmentAtIndex:0];
    [self.segment setTitle:NSLocalizedString(@"Missed Calls", @"Missed Calls") forSegmentAtIndex:1];

	self.navigationItem.title = NSLocalizedString(@"Call History", @"Call History");
    
    mStatusFilter = HistoryEventStatus_All;
    [self refreshData];
   
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:MAIN_COLOR}];

    [self.navigationController.navigationBar setTintColor:MAIN_COLOR];
    
    
    
  //  UIImage *colorImage = [UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)];
    
    
    [self.navigationController.navigationBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setBackgroundImage:[[UIImage alloc]init]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
//    self.editItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"edit", @"edit") style:UIBarButtonItemStylePlain target:self action:@selector(editiAction:)];
//    self.navigationItem.rightBarButtonItem = self.editItem;
    
    
    self.editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"recent_nav_del_ico"] style:UIBarButtonItemStyleDone target:self action:@selector(editiAction:)];
    
    self.editItem.tintColor = MAIN_COLOR;
    self.navigationItem.rightBarButtonItem = self.editItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HSRecentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellID];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footRefresh)];
    
    [self traitCollectionDidChange:self.traitCollection];
}

-(void)footRefresh{
    
    
    NSLog(@"foot refresh");
    
    
    showindex += 10;
    
    
  
    
    if (showindex >mHistoryArray.count) {
        
        showindex = mHistoryArray.count;
        
          [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        
    }else
    {
        
          [self.tableView reloadData];
           [self.tableView.mj_footer endRefreshing];
        
    }
    
    

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshDataAndReload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetEditstatus {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = self.editItem;
    [self.tableView setEditing:NO];
}

#pragma mark - segmentIndexClicked
- (IBAction) segmentIndexClicked:(id)sender
{
    [selectIndexs removeAllObjects];
    [self resetEditstatus];
    
    NSInteger index = [sender selectedSegmentIndex];
    
    switch (index) {
        case 0:
            mStatusFilter = HistoryEventStatus_All;//所有通话
            [self refreshDataAndReload];
            break;
        case 1:
            mStatusFilter = INCOMING_FAILED;//未接电话
            [self refreshDataAndReload];
            break;
        default:
            break;
    }
}

- (void)selectAllAction:(id)sender { // 清除 <==> 全选
    
    if (sender == self.selectAllItem) {
        for (int i = 0; i<mHistoryArray.count; i ++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            
            [selectIndexs addObject:index];
            
            [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }
        self.navigationItem.leftBarButtonItem = self.clearOptions;
    }
    else if (sender == self.clearOptions) {
        
        if (selectIndexs.count == mHistoryArray.count) {
            [self clearHistoryButtonClicked:nil];
            return ;
        }
        
        for (int i = 0; i < selectIndexs.count; i ++) {
            NSIndexPath *indexPath = selectIndexs[i];
            
            NSInteger tempindex = indexPath.row;
            
            if (tempindex >= mHistoryArray.count) {
                
                tempindex = mHistoryArray.count-1;
                
            }
            
//            History *value = mHistoryArray[indexPath.row];

                History *value =mHistoryArray[tempindex];
                [databaseManage deleteAllHistory:value.mMediaType withStatus:value.mStatus withRemoteParty:value.mRemoteParty];
        }
        
        [self refreshData];
        [self.tableView reloadData];
        
        [selectIndexs removeAllObjects];
        self.navigationItem.leftBarButtonItem = self.selectAllItem;
    }
}

- (IBAction)editiAction:(id)sender {
    
    [selectIndexs removeAllObjects];
    
    if (!self.selectAllItem) {
        self.selectAllItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select All", @"Select All") style:UIBarButtonItemStylePlain target:self action:@selector(selectAllAction:)];
    }
    if (!self.doneItem) {
        self.doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(editiAction:)];
    }
    
    if (!self.clearOptions) {
        self.clearOptions = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Delete") style:UIBarButtonItemStylePlain target:self action:@selector(selectAllAction:)];
    }
    
    if (sender == self.editItem) {
        self.navigationItem.leftBarButtonItem = self.selectAllItem;
        self.navigationItem.rightBarButtonItem = self.doneItem;
        if (!selectIndexs) {
            selectIndexs = [NSMutableArray array];
        }
        
        [self.tableView setEditing:YES];
    }
    else if (sender == self.doneItem) {
        
        [self resetEditstatus];
    }

}

#pragma mark - clearHistoryButtonClicked
-(void) clearHistoryButtonClicked:(id)sender
{
    UIActionSheet *popupQuery = nil;
    if (mStatusFilter == HistoryEventStatus_All) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                   destructiveButtonTitle:NSLocalizedString(@"Clear All Entries", @"Clear All Entries")
                                        otherButtonTitles:nil];
    }
    else{
        popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                   destructiveButtonTitle:NSLocalizedString(@"Clear All Entries", @"Clear All Entries")
                                        otherButtonTitles:NSLocalizedString(@"Clear Missed Entries", @"Clear Missed Entries"), nil];
    }

    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    //[popupQuery showInView: [self view]];
    [popupQuery showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [mHistoryArray count];

     return showindex;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     HSRecentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    if(mHistoryArray.count > indexPath.row)
    {
        [cell setHistory:[mHistoryArray objectAtIndex:indexPath.row]];
    }
	
     
     return cell;
}


// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//    }
//}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Delete", @"Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
     //   NSLog(@"indexPath.row==%d",indexPath.row);
        
        
        History* history = [mHistoryArray objectAtIndex: indexPath.row];
        if (history) {
            [databaseManage deleteAllHistory:history.mMediaType withStatus:history.mStatus withRemoteParty:history.mRemoteParty];
        }
        [mHistoryArray removeObjectAtIndex:indexPath.row];
        
        showindex -=1;
        
        if (showindex<0) {
            
            showindex =0;
            
        }
        
        
       // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView reloadData];
        
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *messageAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Message", @"Message") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        History *history = [mHistoryArray objectAtIndex:indexPath.row];
        if (history) {
            
            HSRecentCell *cell = (HSRecentCell *)[tableView cellForRowAtIndexPath:indexPath];
            NSDictionary *dic = [contactView numbers2ContactsMapper];
            Contact* contact = [dic objectForKey:cell.history.mRemoteParty];
            BOOL showCreatOption = NO;
            if(contact == nil){
                showCreatOption = YES;
                CNMutableContact* aContact = [[CNMutableContact alloc] init];
                
                CNLabeledValue *otherEmail = [CNLabeledValue labeledValueWithLabel:CNLabelOther value:cell.remoteParty];
                aContact.emailAddresses =@[otherEmail];
                
                if ([cell.remoteParty containsString:@"@"]) {
                    NSArray *strs = [cell.remoteParty componentsSeparatedByString:@"@"];
                    aContact.givenName =strs[0];
                } else {
                    aContact.givenName =cell.remoteParty;
                }
                
                contact = [[Contact alloc] initWithCNContact:aContact];
            }
            NSString *localParty = [shareAppDelegate getShortRemoteParty:shareAppDelegate.account.LocalUri andCallee:nil];
            chatView.chatSession = [databaseManage getChatSession:localParty RemoteUri:history.mRemoteParty DisplayName:contact.displayName ContactId:contact.contdentifier];
            //[chatView setRemoteParty:history.mRemoteParty andContact:contact withChatType:MediaType_Chat];
            [self.navigationController pushViewController:chatView animated:YES];
        }
        
    }];
    messageAction.backgroundColor = [UIColor lightGrayColor];
    
    return @[deleteAction, messageAction];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.tableView.isEditing) {
        
        [selectIndexs addObject:indexPath];
//        NSLog(@"选了第%d行",indexPath.row);
        
        if (self.navigationItem.leftBarButtonItem == self.selectAllItem) {
            
            self.navigationItem.leftBarButtonItem = self.clearOptions;
        }
        
        return;
    }
     
    HSRecentCell *cell = (HSRecentCell *)[tableView cellForRowAtIndexPath:indexPath];

    
    NSString * tempParty= cell.remoteParty;
    
    
    if ([shareAppDelegate.portSIPHandle.mAccount.transportType isEqualToString:@"UDP"]) {
        
        if ([cell.remoteParty rangeOfString:@":"].location != NSNotFound) {
            
            NSArray *temp = [cell.remoteParty componentsSeparatedByString:@":"];
            
            if (temp .count>0) {
                
                      tempParty = temp[0];
            }
      
            
            
        }
        
    }
    
    
    
    if (cell.history.mMediaType == MediaType_Audio) {
        [[AppDelegate sharedInstance] makeCall:tempParty videoCall:NO];
    }
    else if (cell.history.mMediaType == MediaType_Video ||
             cell.history.mMediaType == MediaType_AudioVideo){
//        [[AppDelegate sharedInstance] makeCall:cell.remoteParty videoCall:YES];
     [[AppDelegate sharedInstance] makeCall:tempParty videoCall:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [selectIndexs removeObject:indexPath];
    if (selectIndexs.count == 0) {
        self.navigationItem.leftBarButtonItem = self.selectAllItem;
    }
}


#pragma mark --
#pragma mark
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    HSRecentCell *cell = (HSRecentCell *)[tableView cellForRowAtIndexPath:indexPath];
    Contact* contact = [contactView getContactByPhoneNumber:cell.history.mRemoteParty];
    BOOL showCreatOption = NO;
    if(contact == nil){
        showCreatOption = YES;
        CNMutableContact* aContact = [[CNMutableContact alloc] init];
        
        CNLabeledValue *otherEmail = [CNLabeledValue labeledValueWithLabel:CNLabelOther value:cell.remoteParty];
        aContact.emailAddresses =@[otherEmail];
        
        if ([cell.remoteParty containsString:@"@"]) {
            NSArray *strs = [cell.remoteParty componentsSeparatedByString:@"@"];
            aContact.givenName =strs[0];
        } else {
            aContact.givenName =cell.remoteParty;
        }
        
        contact = [[Contact alloc] initWithCNContact:aContact];
    }
    
    UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    ContactDetailsViewController* contactDetails = [stryBoard instantiateViewControllerWithIdentifier:@"ContactDetails"];
    //contactDetails.superControllerID = 7;
    contactDetails.contact = contact;
    contactDetails.callHistory = cell.history;
  contactDetails.superControllerID = 2;
    contactDetails.ifFormPhoneCallList = YES;
    
    
    contactDetails.showCreateOption = showCreatOption;
    
    self.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:contactDetails animated:YES];
    
    self.hidesBottomBarWhenPushed = NO;
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return NO;
}


#pragma mark ABUnknownPersonViewControllerDelegate methods
// Dismisses the picker when users are done creating a contact or adding the displayed person properties to an existing contact.
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
//	[self dismissModalViewControllerAnimated:YES];
}


// Does not allow users to perform default actions such as emailing a contact, when they select a contact property.
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
						   property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}

- (void)addNewHistroy:(History*) addHistory
{
    if(!mHistoryArray || !addHistory ||
       !([addHistory mMediaType] & MediaType_AudioVideo) ||
       !([addHistory mStatus] & mStatusFilter)){
            return;
    }
    int flag = 0;
    for (int i = 0 ;i < mHistoryArray.count; i++) {
        History *history = mHistoryArray[i];
        
        if ([history.mRemotePartyDisplayName isEqualToString:addHistory.mRemotePartyDisplayName] && history.mStatus == addHistory.mStatus && history.mMediaType == addHistory.mMediaType) {
            flag = 1;
            history.historyCount += 1;
            
            [mHistoryArray exchangeObjectAtIndex:i withObjectAtIndex:0];
        }
    }
    
    if (flag == 0) {
        addHistory.historyCount = 1;
        [mHistoryArray insertObject:addHistory atIndex:0];
    } else {
        NSSortDescriptor *timeDecriptor = [NSSortDescriptor sortDescriptorWithKey:@"mTimeStart" ascending:NO];
        [mHistoryArray sortUsingDescriptors:@[timeDecriptor]];
    }
    
    [[self tableView] reloadData];
}
//
//	UIActionSheetDelegate
//

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        [databaseManage deleteAllHistory:MediaType_Audio withRemoteParty:nil];
        [databaseManage deleteAllHistory:MediaType_Video withRemoteParty:nil];
        [databaseManage deleteAllHistory:MediaType_AudioVideo withRemoteParty:nil];
        [self cleanBadges];
        [self refreshDataAndReload];
        
        [self resetEditstatus];
        [selectIndexs removeAllObjects];
	}
	else if (buttonIndex == 1 && mStatusFilter != HistoryEventStatus_All) {//删除未接通话
        for (History *history in mHistoryArray) {
            if (IS_EVENT_INCOMING_FAILED(history.mStatus)) {
                [databaseManage deleteHistory:history.mHistoryID];
            }
        }
        [self cleanBadges];
        [self refreshDataAndReload];
	}
}

- (void)cleanBadges
{
    Options *options = [databaseManage mOptions];
    options.mCallBadge = 0;
    [databaseManage saveOptions];
    
    [shareAppDelegate refreshItemBadge];
}
@end
