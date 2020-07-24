//
//  ContactViewController.m
//  PortGo
//
//  Created by Joe Lepple on 4/8/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "ContactViewController.h"
#import "NSString+HSFilterString.h"
#import "DataBaseManage.h"
#import "AppDelegate.h"
#import "HSFavoriteCell.h"
#import "UIColor_Hex.h"
#import "ContactCell.h"
#import "AddorEditViewController.h"
#import "MLTabBarController.h"
#import "UINavigationController+InterfaceOrientation.h"
#import "TextImageView.h"
#import "Account.h"

#import "ServerContactModel.h"
#import "GetJson.h"


#undef  PortCFRelease
#define PortCFRelease(x) if(x)CFRelease(x), x=NULL;

@interface ContactViewController(Private)


-(void) initContacts;

-(void) refreshData;
-(void) reloadData;
-(void) refreshDataAndReload;

-(BOOL)isNullOrEmpty:(NSString*)string;
@end

#if TARGET_OS_IPHONE

static void NgnAddressBookCallbackForElements(const void *value, void *context)
{
    ContactViewController* self_ = (__bridge ContactViewController*)context;
    
    const ABRecordRef* record = (const ABRecordRef*)value;
    Contact* contact = [[Contact alloc] initWithABRecordRef:record];
    if(contact){
        if (contact.phoneNumbers.count > 0) {
            for(NgnPhoneNumber *phoneNumber in contact.phoneNumbers){
                if(phoneNumber.number){
                    [(NSMutableDictionary*)[self_ numbers2ContactsMapper] setObject:contact forKey:[phoneNumber.number stringWithFilterPhoneNumber:phoneNumber.number]];
                }
            }
        }
        if(contact.IPCallNumbers.count > 0) {
            for (NSDictionary *IPCall in contact.IPCallNumbers) {
                NSString *key = [IPCall allKeys][0];
                NSString *value = [IPCall objectForKey:key];
                [(NSMutableDictionary*)[self_ numbers2ContactsMapper] setObject:contact forKey:value];
            }
        }
        
        [(NSMutableArray*)[self_ contacts] addObject: contact];
    }
}

static CFComparisonResult NgnAddressBookCompareByCompositeName(ABRecordRef person1, ABRecordRef person2, ABPersonSortOrdering ordering)
{
    CFStringRef displayName1 = ABRecordCopyCompositeName(person1);
    CFStringRef displayName2 = ABRecordCopyCompositeName(person2);
    //CFComparisonResult result = kCFCompareEqualTo;CFStringCompareFlags
    if(displayName1 == nil)
        return kCFCompareLessThan;
    else if(displayName2 == nil)
        return kCFCompareGreaterThan;
    
    CFComparisonResult result = CFStringCompare(displayName1, displayName2, 0);
    return result;
}

#endif /* TARGET_OS_IPHONE */

@implementation ContactViewController(Private)

-(BOOL)isNullOrEmpty:(NSString*)string{
    return string == nil || string==(id)[NSNull null] || [string isEqualToString: @""];
}

-(void) initContacts
{
    if (!deleteAccounts) {
        deleteAccounts = [[NSMutableArray alloc] init];
    }
    if (!deleteIndexPaths) {
        deleteIndexPaths = [[NSMutableArray alloc] init];
    }
    if(!mContacts){
        mContacts = [[NSMutableDictionary alloc] init];
    }
    
    if(!mAllContacts){
        mAllContacts = [[NSMutableArray alloc] init];
    }
    
    if(!mNumbers2ContacstMapper){
        mNumbers2ContacstMapper = [[NSMutableDictionary alloc] init];
    }
    
    sipOnlineArr = [[NSMutableArray alloc] init];
    
    
    sipOfflineArr = [[NSMutableArray alloc]init];
    
    
    
    
    
    //#ifdef __IPHONE_9_0
    [self syncLoadSystemContact];
    //#else
    //    [self syncLoad];
    //#endif
    
}

- (void)allDataRangerwithArry:(NSMutableArray *)arr {
    [mContacts removeAllObjects];
    [orderedSections removeAllObjects];
    
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    if (self.segment.selectedSegmentIndex == 0 || self.segment.selectedSegmentIndex == 1) {
        
        for (Contact* contact in arr) {
            NSString *dispalyName = contact.displayName;
            if (dispalyName) {
                NSInteger sectionNumber = [collation sectionForObject:dispalyName collationStringSelector:@selector(self)];
                NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
                [sectionNames addObject:contact];
            }
            
        }
    }
    
    else if(self.segment.selectedSegmentIndex == 2) {
        for (Favorite *favorite in arr) {
            NSString *displayName = favorite.mDisplayName;
            NSInteger sectionNumber = [collation sectionForObject:displayName collationStringSelector:@selector(self)];
            NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
            [sectionNames addObject:favorite];
        }
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    [newSectionsArray enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL *stop) {
        if (arr.count == 0) {
            
        } else {
            [temp addObject:[collation sectionTitles][idx]];
            [mContacts setObject:arr forKey:[collation sectionTitles][idx]];
            
        }
    }];
    orderedSections = [NSMutableArray arrayWithArray:temp];
}


#pragma mark --
#pragma mark

-(void)refreshData{
    if (self.segment.selectedSegmentIndex == 0 && mAllContacts) {
        
        if(self.mSearchDisplay.active){
            [self allDataRangerwithArry:mSearchResult];
        }else{
            [self allDataRangerwithArry:mAllContacts];
        }
    }
    
    else if (self.segment.selectedSegmentIndex == 1 && sipFriends) {
        [self sipFriends];
    }
    
    else if (self.segment.selectedSegmentIndex == 2 && mFavoritersArray) {
        //    [self allDataRangerwithArry:mFavoritersArray];
        [self getfavFriends];
        
    }
    self.tableView.tableFooterView = _footerLabel;
}

-(void) reloadData{
    [self.tableView reloadData];
}

-(void) refreshDataAndReload{
    [self refreshData];
    
    [self reloadData];
}

@end
@interface ContactViewController () <UIScrollViewDelegate>
{
    BOOL _isSelect;
    BOOL _isAllSelect;
    
    NSInteger _deleteNum ;
    UIBarButtonItem *_mAddContactsButton;
    UIBarButtonItem* _mSelectButton;
    UIView* _bottomView;
    UIButton* deleteButton;
    UIButton *lastSelectButton;
    
    
    
    
    UIView  * tempview ;
    
    
}
@end

@implementation ContactViewController
#pragma mark - removeCNcontacts
-(void)removeCNContacts:(NSArray *)contacts {
    
    if (self.segment.selectedSegmentIndex == 1) {
        [self sipFriends];
    } else {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        NSArray * keys = @[CNContactIdentifierKey];
        CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            NSString *identifi = contact.identifier;
            for (int i = 0; i < contacts.count; i ++) {
                Contact *mContact = contacts[i];
                if ([identifi isEqualToString:mContact.contdentifier]) {
                    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
                    [saveRequest deleteContact:[contact mutableCopy]];
                    [contactStore executeSaveRequest:saveRequest error:nil];
                }
            }
        }];
        
        [self syncLoadSystemContact];
        
        
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        //FIXME: orderedSections LastValue not go forStateMent
        for (int i = 0; i<orderedSections.count; i++) {
            NSArray *tem = [mContacts objectForKey:orderedSections[i]];
            if (tem.count == 0) { // section下的值个数为0时 删除section
                [mContacts removeObjectForKey:orderedSections[i]];
                [orderedSections removeObjectAtIndex:i];
                [self.tableView beginUpdates];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
        [self refreshDataAndReload];
        
    }
}




#pragma mark --
#pragma mark


-(void)deletesip:(Contact*)contacttemp{
    NSArray *keyFentch = @[CNContactFamilyNameKey, CNContactGivenNameKey,CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactSocialProfilesKey, CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactInstantMessageAddressesKey];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    
    CNMutableContact *contact = nil;
    
    
    contact = [[store unifiedContactWithIdentifier:contacttemp.contdentifier keysToFetch:keyFentch error:nil] mutableCopy];
    
    CNInstantMessageAddress *IMSData = [[CNInstantMessageAddress alloc]initWithUsername:@"" service:@"IM"];
    
    CNLabeledValue *IMS = [CNLabeledValue labeledValueWithLabel:nil value:IMSData];
    
    contact.instantMessageAddresses = @[IMS];
    
    [self updateContact:contact];
}

- (void)updateContact:(CNMutableContact *)contact{
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest updateContact:contact];
    CNContactStore *store = [[CNContactStore alloc] init];
    [store executeSaveRequest:saveRequest error:nil];
}


#pragma mark - removeABContacts
-(void)removeAddressBookContacts:(NSArray *)contacts {
    
    if (ABAddressBookGetAuthorizationStatus()!=kABAuthorizationStatusAuthorized) return;
    
    mAddressBook = ABAddressBookCreate();
    NSArray* array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(mAddressBook);
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        //        NSDate* creatDate = (__bridge NSDate*)ABRecordCopyValue(people, kABPersonCreationDateProperty);
        int32_t recordID = ABRecordGetRecordID(people);
        for (int i = 0; i < contacts.count; i ++) {
            Contact* contact = contacts[i];
            if (recordID == contact.contactId) {
                ABAddressBookRemoveRecord(mAddressBook, people, NULL);
            }
            
        }
    }
    
    ABAddressBookSave(mAddressBook,NULL);
    
    if (mAddressBook) {
        CFRelease(mAddressBook);
    }
    
    [self syncLoad];
    
    if (self.segment.selectedSegmentIndex == 1) {
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
    for (int i = 0; i<orderedSections.count; i++) {
        NSArray *tem = [mContacts objectForKey:orderedSections[i]];
        if (tem.count == 0) {
            [mContacts removeObjectForKey:orderedSections[i]];
            [orderedSections removeObjectAtIndex:i];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }
    [self refreshDataAndReload];
}

-(void)initAllContacts {
    if (!mAllContacts) {
        mAllContacts = [NSMutableArray array];
    }
    if (!mNumbers2ContacstMapper) {
        mNumbers2ContacstMapper = [NSMutableDictionary dictionary];
    }
    if (mAllContacts.count == 0) {
        [self syncLoadSystemContact];
    }
    
}

#pragma mark - LoadCNContacts
-(void)syncLoadSystemContact {
    NSMutableDictionary *statusDic = [NSMutableDictionary new];
    for(Contact *myContact in mAllContacts){
        if(myContact.IMNumber!=nil){
            if(myContact.stateText != nil){
                [statusDic setValue:myContact.stateText forKey:myContact.contdentifier];
            }
        }
    }
    
    [mAllContacts removeAllObjects];
    [mNumbers2ContacstMapper removeAllObjects];
    
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                NSArray *keys = @[CNContactIdentifierKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactSocialProfilesKey,CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactOrganizationNameKey,CNContactDepartmentNameKey, CNContactJobTitleKey,CNContactInstantMessageAddressesKey];
                
                CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
                [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                    Contact *myContact = [[Contact alloc] initWithCNContact:contact];
                    if(myContact){
                        if (myContact.phoneNumbers.count > 0) {
                            for(NgnPhoneNumber *phoneNumber in myContact.phoneNumbers){
                                if(phoneNumber.number){
                                    [mNumbers2ContacstMapper setObject:myContact forKey:[phoneNumber.number stringWithFilterPhoneNumber:phoneNumber.number]];
                                }
                            }
                        }
                        if(myContact.IPCallNumbers.count > 0) {
                            for (NSDictionary *IPCall in myContact.IPCallNumbers) {
                                NSString *key = [IPCall allKeys][0];
                                NSString *value = [IPCall objectForKey:key];
                                [mNumbers2ContacstMapper setObject:myContact forKey:value];
                            }
                        }
                    }
                    NSString *status = [statusDic valueForKey:myContact.contdentifier];
                    if(status == NULL||status.length==0){
                        myContact.stateText = @"Offline";
                    }else{
                        myContact.stateText = status;
                    }
                    
                    [mAllContacts addObject:myContact];
                    
                }];
                
                [self refreshData];
            }
        }];
    }
    else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        NSArray *keys = @[CNContactIdentifierKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactSocialProfilesKey,CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactOrganizationNameKey,CNContactDepartmentNameKey, CNContactJobTitleKey,CNContactNicknameKey,CNContactInstantMessageAddressesKey];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            Contact *myContact = [[Contact alloc] initWithCNContact:contact];
            if(myContact){
                if (myContact.phoneNumbers.count > 0) {
                    for(NgnPhoneNumber *phoneNumber in myContact.phoneNumbers){
                        if(phoneNumber.number){
                            [mNumbers2ContacstMapper setObject:myContact forKey:[phoneNumber.number stringWithFilterPhoneNumber:phoneNumber.number]];
                        }
                    }
                }
                if(myContact.IPCallNumbers.count > 0) {
                    for (NSDictionary *IPCall in myContact.IPCallNumbers) {
                        NSString *key = [IPCall allKeys][0];
                        NSString *value = [IPCall objectForKey:key];
                        [mNumbers2ContacstMapper setObject:myContact forKey:value];
                    }
                }
            }
            
            NSString *status = [statusDic valueForKey:myContact.contdentifier];
            if(status == NULL||status.length==0){
                myContact.stateText = @"Offline";
            }else{
                myContact.stateText = status;
            }
            
            [mAllContacts addObject:myContact];
            
        }];
    }
    else {
        return;
    }
    
    if(mAllContacts.count >0){
        NSMutableArray* mFavoriters = [[NSMutableArray alloc] init];
        mFavoritersArray = [databaseManage loadFavorites];
        for(Favorite *favorite in mFavoritersArray){
            BOOL find = NO;
            for(Contact* contact in mAllContacts){
                if([contact.contdentifier isEqualToString:favorite.mFavoriteIdentifi]){
                    if (contact.phoneNumbers.count > 0) {
                        for(NgnPhoneNumber* number in [contact phoneNumbers]){
                            if(favorite.mPhoneType == [number type]&& [favorite.mPhoneNum isEqualToString:[number number]]){
                                find = YES;
                                break;
                            }
                        }
                    } else {
                        if (contact.IPCallNumbers.count > 0) {
                            for(NSDictionary* IPNumber in [contact IPCallNumbers]){
                                NSString *key = [IPNumber allKeys][0];
                                if(favorite.mPhoneType == NgnPhoneNumberType_IPCall && [favorite.mPhoneNum isEqualToString:IPNumber[key]]){
                                    find = YES;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if(!find){
                [mFavoriters addObject:favorite];
            }
        }
        if(mFavoriters.count>0){
            for(Favorite *favorite in mFavoriters){
                [databaseManage removeFavorite:favorite];
                [mFavoritersArray removeObject:favorite];
            }
            
        }
    }else{
        [mFavoritersArray removeAllObjects];
        
        if (!mFavoritersArray) {
            mFavoritersArray = [NSMutableArray array];
        }
    }
}

#pragma mark - LoadABContcat
-(void)syncLoad{
    [mAllContacts removeAllObjects];
    [mNumbers2ContacstMapper removeAllObjects];
    
    //        if(mAddressBook == nil){
    CFErrorRef myError = NULL;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        mAddressBook = ABAddressBookCreateWithOptions(NULL, &myError);
        ABAddressBookRequestAccessWithCompletion(mAddressBook, ^(bool granted, CFErrorRef error){
            if (granted)
            {
                if(mAddressBook){
                    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(mAddressBook);
                    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
                                                                               kCFAllocatorDefault,
                                                                               CFArrayGetCount(people),
                                                                               people
                                                                               );
                    CFArraySortValues(
                                      peopleMutable,
                                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                                      (CFComparatorFunction) NgnAddressBookCompareByCompositeName,
                                      (void*)ABPersonGetSortOrdering()
                                      );
                    
                    // Create NGN contacts
                    CFArrayApplyFunction(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), NgnAddressBookCallbackForElements, (__bridge void *)(self));
                    PortCFRelease(peopleMutable);
                    PortCFRelease(people);
                }
                [self refreshData];
                //userAllow();
            }
            else
            {
                //userForbid();
            }
        });
        
        //CFRelease(addressBookRef);
    }
    else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        mAddressBook = ABAddressBookCreateWithOptions(NULL, &myError);
        if(mAddressBook){
            CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(mAddressBook);
            CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
                                                                       kCFAllocatorDefault,
                                                                       CFArrayGetCount(people),
                                                                       people
                                                                       );
            CFArraySortValues(
                              peopleMutable,
                              CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                              (CFComparatorFunction) NgnAddressBookCompareByCompositeName,
                              (void*) ABPersonGetSortOrdering()
                              );
            
            // Create NGN contacts
            CFArrayApplyFunction(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), NgnAddressBookCallbackForElements, (__bridge void *)(self));
            
            PortCFRelease(peopleMutable);
            PortCFRelease(people);
        }
    }
    else
    {
        return;
        //kABAuthorizationStatusDenied
        //kABAuthorizationStatusRestricted;
    }
    //        }
    
    if(mAllContacts.count >0){
        NSMutableArray* mFavoriters = [[NSMutableArray alloc] init];
        mFavoritersArray = [databaseManage loadFavorites];
        for(Favorite *favorite in mFavoritersArray){
            BOOL find = NO;
            for(Contact* contact in mAllContacts){
                if([contact contactId] == favorite.mFavoriteId){
                    if (contact.phoneNumbers.count > 0) {
                        for(NgnPhoneNumber* number in [contact phoneNumbers]){
                            if(favorite.mPhoneType == [number type]&& [favorite.mPhoneNum isEqualToString:[number number]]){
                                find = YES;
                                break;
                            }
                        }
                    } else {
                        if (contact.IPCallNumbers.count > 0) {
                            for(NSDictionary* IPNumber in [contact IPCallNumbers]){
                                NSString *key = [IPNumber allKeys][0];
                                if(favorite.mPhoneType == NgnPhoneNumberType_IPCall && [favorite.mPhoneNum isEqualToString:IPNumber[key]]){
                                    find = YES;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if(!find){
                [mFavoriters addObject:favorite];
            }
        }
        if(mFavoriters.count>0){
            for(Favorite *favorite in mFavoriters){
                [databaseManage removeFavorite:favorite];
                [mFavoritersArray removeObject:favorite];
            }
            
        }
    }else{
        [mFavoritersArray removeAllObjects];
    }
}

-(NSMutableArray *)getSipContacts {
    if (![databaseManage mSIPContacts]) {
        [databaseManage loadSIPFriends];
    }
    return [databaseManage mSIPContacts];
}

-(NSMutableArray *)getSipFriendsAndContacts {
    [mAllContacts addObjectsFromArray:sipFriends];
    return mAllContacts;
}

-(void)addSipContacts:(Contact *)sipfriend {
    NSMutableArray *arr = [databaseManage mSIPContacts];
    [arr addObject:sipfriend];
}

-(void)editSipContacts:(Contact *)sipfriend {
    NSMutableArray *arr = [databaseManage mSIPContacts];
    for (Contact *value in arr) {
        if ([value.displayName isEqualToString:sipfriend.displayName]) {
            //替换sipFriends;
            [arr replaceObjectAtIndex:[arr indexOfObject:value] withObject:sipfriend];
        }
    }
}


#pragma mark - loadSIPFriendsFromDataBase
-(void)getSipFriendsDataSource { //获取SipFriend并且转换成Contact
    [sipFriends removeAllObjects];
    if (!sipFriends) {
        sipFriends = [NSMutableArray array];
    }
    //    [mNumbers2ContacstMapper removeAllObjects];
    
    NSMutableArray *sipfriends = [self getSipContacts];
    for (Contact *myContact in sipfriends) {
        if (myContact.phoneNumbers.count > 0) {
            for(NgnPhoneNumber *phoneNumber in myContact.phoneNumbers){
                if(phoneNumber.number){
                    [mNumbers2ContacstMapper setObject:myContact forKey:[phoneNumber.number stringWithFilterPhoneNumber:phoneNumber.number]];
                }
            }
        }
        if(myContact.IPCallNumbers.count > 0) {
            for (NSDictionary *IPCall in myContact.IPCallNumbers) {
                NSString *key = [IPCall allKeys][0];
                NSString *value = [IPCall objectForKey:key];
                [mNumbers2ContacstMapper setObject:myContact forKey:value];
            }
        }
        [sipFriends addObject:myContact];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        mAllContacts = [[NSMutableArray alloc] init];
        mNumbers2ContacstMapper = [[NSMutableDictionary alloc] init];
        // Custom initialization
    }
    return self;
}

-(void)shuaxin1{
    
    //[self.segment setSelectedSegmentIndex:0];
    [self refreshDataAndReload];
}


-(void)shuaxinview{
    [self viewDidLoad];
}


#pragma mark --
#pragma mark viewDidLoad
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor,*bkColorLight;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
        bkColorLight =[UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColor = [UIColor whiteColor];
        bkColorLight= [UIColor lightGrayColor];
    }
    
    _pageTitleView.backgroundColor= bkColor;
    self.tableView.backgroundColor= bkColor;
    self.view.backgroundColor = bkColor;
    
    [self.navigationController.navigationBar setBackgroundColor:bkColor];
    [self.navigationController.navigationBar setBarTintColor:bkColor];
    [self.tabBarController.tabBar setBarTintColor:bkColor];
    
    UIView *tableBackgroundView = [[UIView alloc]initWithFrame:self.tableView.bounds];
    tableBackgroundView.backgroundColor = bkColor;
    self.tableView.backgroundView = tableBackgroundView;
    
    if (@available(iOS 13.0, *)) {
        _mSearchDisplay.searchBar.barTintColor = bkColor;
        _mSearchDisplay.searchBar.searchTextField.backgroundColor = bkColorLight;
    }
    
    [self refreshDataAndReload];
}

- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shuaxinview) name:@"shuaxinview" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shuaxin1) name:@"shuaxin1" object:nil];
    
    
    NSArray *titleArr = @[NSLocalizedString(@"All", @"All"), NSLocalizedString(@"online", @"online"), NSLocalizedString(@"offline", @"offline")];
    
    SGPageTitleViewConfigure *configure = [SGPageTitleViewConfigure pageTitleViewConfigure];
    configure.indicatorScrollStyle = SGIndicatorScrollStyleHalf;
    configure.titleFont = [UIFont systemFontOfSize:12];
    configure.titleColor = MAIN_COLOR;
    configure.titleSelectedColor = MAIN_COLOR_LIGHT;
    configure.indicatorColor = MAIN_COLOR_LIGHT;
    
    
    _pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50) delegate:self titleNames:titleArr configure:configure];
    
    
    _pageTitleView.isTitleGradientEffect = NO;
    _pageTitleView.selectedIndex = 0;
    _pageTitleView.isNeedBounces = NO;
    
    [self.segment setTitle:NSLocalizedString(@"Contacts", @"Contacts")  forSegmentAtIndex:0];
    [self.segment setTitle:NSLocalizedString(@"Friends", @"Friends") forSegmentAtIndex:1];
    [self.segment setTitle:NSLocalizedString(@"Favorites", @"Favorites") forSegmentAtIndex:2];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:MAIN_COLOR}];
    [self.navigationController.navigationBar setTintColor:MAIN_COLOR];
    
    
    [self.navigationController.navigationBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setBackgroundImage:[[UIImage alloc]init]];
    
    [self.tableView setSeparatorColor:[UIColor colorWithHexString:@"#f0f0f0"]];
    
    [self initContacts];
    
    // load data and register for notifications
    [self refreshData];
    _mAddContactsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contact_nav_ico_add_contact_def"] style:UIBarButtonItemStyleDone target:self action:@selector(addContactsButtonClicked:)];
    
    _mAddContactsButton.tintColor = MAIN_COLOR;
    self.navigationItem.rightBarButtonItem = _mAddContactsButton;
    
    _mSelectButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"Select") style:UIBarButtonItemStylePlain target:self action:@selector(selectContactsButtonClicked:)];
    _mSelectButton.tintColor = MAIN_COLOR;
    self.navigationItem.leftBarButtonItem = _mSelectButton;
    
    _footerLabel = (UILabel *)[self setUpFooterView];
    self.tableView.tableFooterView = _footerLabel;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.sectionIndexColor = [UIColor grayColor];
    self.tableView.sectionIndexBackgroundColor = [[UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1] colorWithAlphaComponent:0];
    self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1] colorWithAlphaComponent:0];
    
    
    self.mSearchDisplay = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.mSearchDisplay.searchResultsUpdater = self;
    self.mSearchDisplay.delegate = self;
    self.mSearchDisplay.definesPresentationContext = true;
    self.mSearchDisplay.dimsBackgroundDuringPresentation = false;
    
    self.tableView.sectionHeaderHeight = 30 ;
    
    [self.tableView setEditing:NO animated:YES];
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.mSearchDisplay.searchBar;
    self.tableView.tableFooterView = [UIView new];
    mSearching = NO;
    mLetUserSelectRow = YES;
    
    [self  sendoncepresenceSubscribe];
    [self traitCollectionDidChange:self.traitCollection];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if(@available(iOS 11.0, *)){
        
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(20,0, 0, 0); //IEdgeInsetsZero;
        [self.tableView layoutIfNeeded];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.hidesBottomBarWhenPushed = NO;
    if([self.segment selectedSegmentIndex] == 2){
        self.navigationItem.leftBarButtonItem = nil;
        
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined || [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
            mFavoritersArray = [databaseManage loadFavorites];
        }
    }
    
    
    [self refreshDataAndReload];
    
    
    [UIApplication sharedApplication].statusBarStyle = 0;
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentIndexClicked:(id)sender
{
    NSInteger index = [sender selectedSegmentIndex];
    
    if(index == 0 || index == 1){
        self.tableView.tableHeaderView = self.mSearchDisplay.searchBar;
        self.navigationItem.leftBarButtonItem = _mSelectButton;
        
        _frommessage = NO;
        if (index==1) {
            self.navigationItem.leftBarButtonItem = nil;
            _frommessage = YES;
        }
        
        
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.tableView.tableHeaderView = nil;
        _frommessage = NO;
        
    }
    
    [self refreshDataAndReload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ContactDetailsViewController *contactDetailsViewController = segue.destinationViewController;
    
    if([orderedSections count] > indexPath.section){
        NSMutableArray* values = [mContacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
        Contact* contact = [values objectAtIndex: indexPath.row];
        if(contact && contact.displayName){
            
            contactDetailsViewController.contact = contact;
            contactDetailsViewController.superControllerID = 2;
            contactDetailsViewController.superIndex = self.segment.selectedSegmentIndex;
            
        }
    }
    
}

#pragma mark --
#pragma mark SGTopScrollMenu
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    
    // NSLog(@"selectedIndex=====%d",selectedIndex);
    sipbuttonindex = selectedIndex;
    
    [self sipFriends];
    
    if (selectedIndex==0) {
    }else if(selectedIndex==1){
        
    }else if(selectedIndex==2){
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (self.segment.selectedSegmentIndex == 1) {
        return 1;
    }
    
    if (self.segment.selectedSegmentIndex == 2) {
        return 1;
    }
    
    
    return orderedSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.segment.selectedSegmentIndex == 1) {
        if(self.mSearchDisplay.active){
            return mSearchResult.count;
        }
        
        if(sipbuttonindex==0){
            return sipFriends.count;
        }else if(sipbuttonindex==1)
        {
            return sipOnlineArr.count;
        }else{
            return sipOfflineArr.count;
        }
    }
    
    if (self.segment.selectedSegmentIndex==2) {
        mFavoritersArray = [self getfavFriends];
        return  mFavoritersArray.count;
    }
    
    if (orderedSections.count > section) {
        NSMutableArray *value = [mContacts objectForKey:[orderedSections objectAtIndex:section]];
        return [value count];
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.segment.selectedSegmentIndex == 1) {
        return 50 ;
    }
    
    return 30.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.segment.selectedSegmentIndex == 1) {
        // return nil;
        return  self.pageTitleView;
    }
    
    if (self.segment.selectedSegmentIndex ==2) {
        return nil;
    }
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30.0)];
    BOOL isDark = false;
    if (@available(iOS 11.0, *)) {
        sectionView.backgroundColor = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        sectionView.backgroundColor = [UIColor lightGrayColor];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 30)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    
    titleLabel.text = orderedSections[section];
    [sectionView addSubview:titleLabel];
    
    sectionView.tag = 100 + section;
    
    return sectionView;
}

-(UIView *)creatSectionView {
    UIView* firstSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 60)];
    firstSection.backgroundColor = [UIColor whiteColor];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 59, firstSection.bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [firstSection addSubview:line];
    
    UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    allButton.frame = CGRectMake(0, 0, firstSection.bounds.size.width / 3, 59);
    [allButton setTitle:@"全部" forState:UIControlStateNormal];
    allButton.tag = 10;
    [allButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [allButton addTarget:self action:@selector(lookSipStateACtion:) forControlEvents:UIControlEventTouchUpInside];
    
    lastSelectButton = allButton;
    
    [firstSection addSubview:allButton];
    
    UIButton *online = [UIButton buttonWithType:UIButtonTypeCustom];
    online.frame = CGRectMake(firstSection.bounds.size.width / 3, 0, self.tableView.bounds.size.width / 3, 59);
    [online setTitle:@"在线" forState:UIControlStateNormal];
    online.tag = 11;
    [online setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [online addTarget:self action:@selector(lookSipStateACtion:) forControlEvents:UIControlEventTouchUpInside];
    
    [firstSection addSubview:online];
    
    UIButton *offline = [UIButton buttonWithType:UIButtonTypeCustom];
    offline.frame = CGRectMake(2*firstSection.bounds.size.width / 3, 0, self.tableView.bounds.size.width / 3, 59);
    [offline setTitle:@"离线" forState:UIControlStateNormal];
    offline.tag = 12;
    [offline setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [offline addTarget:self action:@selector(lookSipStateACtion:) forControlEvents:UIControlEventTouchUpInside];
    
    [firstSection addSubview:offline];
    
    return firstSection;
}

-(void)lookSipStateACtion:(UIButton *)sender {
    [lastSelectButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sender setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    lastSelectButton = sender;
    
}


#pragma mark - cellForRowAtIndexPath

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (self.segment.selectedSegmentIndex == 2) {
        static NSString *cellID = @"Favorite";
        ContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!contactCell) {
            contactCell = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil][0];
        }
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        Favorite *favorite;
        if (self.mSearchDisplay.active) {
            favorite = mSearchResult[row];
        }else{
            favorite = [mFavoritersArray objectAtIndex:indexPath.row];
        }
        if (favorite && favorite.mDisplayName) {
            contactCell.contactDisplayName.text = favorite.mDisplayName;
        }
        
        CNContactStore *store = [[CNContactStore alloc] init];
        CNContact *person = [store unifiedContactWithIdentifier:favorite.mFavoriteIdentifi keysToFetch:@[CNContactImageDataKey,CNContactImageDataAvailableKey] error:nil];
        if (person.imageData) {
            contactCell.contactIcon.image = [UIImage imageWithData:person.imageData] ;
        }
        
        else {
            contactCell.contactIcon.hidden = YES;
            TextImageView *textImage = [[TextImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
            textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:20];
            textImage.raduis = 20.0;
            [contactCell.contentView addSubview:textImage];
            if ([self includeChinese:favorite.mDisplayName]) {
                if (favorite.mDisplayName.length < 2) {
                    textImage.string = [favorite.mDisplayName substringToIndex:1];
                    return contactCell;
                }
                NSString *substing = [favorite.mDisplayName substringToIndex:2];
                if ([self includeChinese:substing]) {
                    textImage.textImageLabel.text = [favorite.mDisplayName substringToIndex:1];
                    return contactCell ;
                }
            }
            if ([favorite.mDisplayName length] >= 2) {
                
                NSString * tempstr = [favorite.mDisplayName substringFromIndex:favorite.mDisplayName.length-1];
                
                
                if ([favorite.mDisplayName containsString:@" "] && ![tempstr isEqualToString:@" "] ) {
                    NSArray *strs = [favorite.mDisplayName componentsSeparatedByString:@" "];
                    NSString *first = strs[0];
                    NSString *last = strs[1];
                    
                    if (first.length<1) {
                        
                        first =@" ";
                    }
                    
                    if (last.length <1) {
                        
                        last = @" ";
                    }
                    
                    textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
                } else {
                    textImage.textImageLabel.text = [favorite.mDisplayName substringToIndex:2];
                }
            } else {
                textImage.textImageLabel.text = [favorite.mDisplayName substringToIndex:1];
            }
            
        }
        //   }
        return contactCell;
    }
    
    if (self.segment.selectedSegmentIndex == 1) {
        
        static NSString *sipCellID = @"sipContactcell";
        ContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier:sipCellID];
        if (!contactCell) {
            contactCell = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil][0];
        }
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        Contact *contact;
        if(self.mSearchDisplay.active){
            contact = mSearchResult[row];
        }else if (sipbuttonindex ==0) {
            contact = sipFriends[indexPath.row];
        }else if (sipbuttonindex ==1){
            contact = sipOnlineArr[indexPath.row];
        }else{
            contact = sipOfflineArr[indexPath.row];
        }
        
        //   Contact *contact = sipFriends[indexPath.row];
        NSString *display = nil;
        if (contact.displayName && ![contact.displayName isEqualToString:@""]) {
            display = contact.displayName;
        } else {
            display = [contact.firstName isEqualToString:@""] ? contact.lastName : contact.firstName;
        }
        
        contactCell.contactDisplayName.text = display;
        UILabel *zhuangtailab = [[UILabel alloc]init];
        zhuangtailab.textColor = [UIColor lightGrayColor];
        zhuangtailab.text = contact.stateText;
        
        //    NSLog(@"contact.stateText====%@",contact.stateText);
        
        zhuangtailab.font =[UIFont systemFontOfSize:12];
        
        zhuangtailab.frame =CGRectMake(contactCell.contactDisplayName .frame.origin.x, contactCell.contactDisplayName .frame.origin.y+20, contactCell.contactDisplayName .frame.size.width, contactCell.contactDisplayName .frame.size.height);
        //     [contactCell.contentView addSubview:zhuangtailab];
        
        
        
        
        UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWid - 130, 10, 100, 40)];
        
        stateLabel.font = [UIFont systemFontOfSize:12];
        
        [contactCell.contentView addSubview:stateLabel];
        
        UIImageView *stateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWid - 25, 23, 14, 14)];
        
        stateLabel.textColor = [UIColor lightGrayColor];
        stateLabel.text = contact.stateText;
        
        if([contact.stateText isEqualToString:NSLocalizedString(@"Available", @"Available")]){
            
            stateLabel.text  = NSLocalizedString(@"online", @"online");
            
        }
        
        if([contact.stateText isEqualToString:NSLocalizedString(@"Online", @"Online")]){
            
            stateLabel.text  = NSLocalizedString(@"online", @"online");
            
        }
        
        if([contact.stateText isEqualToString:NSLocalizedString(@"Offline", @"Offline")]){
            
            stateLabel.text  = NSLocalizedString(@"offline", @"offline");
            
        }
        
        
        stateLabel.textAlignment  = NSTextAlignmentRight;
        
        //      stateIcon.image = [UIImage imageNamed:@"contact_details_outline_ico"];
        
        [contactCell.contentView addSubview:stateIcon];
        
        //   NSLog(@"contact.onlineState======%@",contact.onlineState);
        
        
        if ([contact.stateText isEqualToString:NSLocalizedString(@"online", @"online")] || [contact.stateText isEqualToString:NSLocalizedString(@"Available", @"Available")]  ||[contact.stateText isEqualToString:NSLocalizedString(@"Online", @"Online")]) {
            
            stateIcon.image = [UIImage imageNamed:@"set_status_online"];
            
        }
        else if ([contact.stateText isEqualToString:NSLocalizedString(@"Away", @"Away")]){
            stateIcon.image = [UIImage imageNamed:@"set_status_away"];
        }
        else if ([contact.stateText isEqualToString:NSLocalizedString(@"Do not disturb", @"Do not disturb")]){
            stateIcon.image = [UIImage imageNamed:@"set_status_shutup"];
        }
        else if ([contact.stateText isEqualToString:NSLocalizedString(@"Busy", @"Busy")]){
            stateIcon.image = [UIImage imageNamed:@"mid_content_status_busy_ico"];
        }
        else if ([contact.stateText isEqualToString:NSLocalizedString(@"Offline", @"Offline") ]  || [contact.stateText isEqualToString:NSLocalizedString(@"offline", @"offline") ] ){
            
            stateIcon.image = [UIImage imageNamed:@"contact_details_outline_ico"];
        }
        
        
        if (contact && contact.picture) {
            contactCell.contactIcon.image = [UIImage imageWithData:contact.picture];
        } else {
            contactCell.contactIcon.hidden = YES;
            TextImageView *textImage = [[TextImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
            textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:20];
            textImage.raduis = 20.0;
            [contactCell.contentView addSubview:textImage];
            
            if ([self includeChinese:display]) {
                if (display.length < 2) {
                    textImage.string = [display substringToIndex:1];
                    return contactCell;
                }
                NSString *substring = [display substringToIndex:2];
                if ([self includeChinese:substring]) {
                    textImage.string = [display substringToIndex:1];
                    return contactCell;
                }
            }
            if ([display length] >= 2) {
                
                NSString * tempstr = [display substringFromIndex:display.length-1];
                
                if ([display containsString:@" "] &&  ![tempstr isEqualToString:@" "]) {
                    NSArray *strs = [display componentsSeparatedByString:@" "];
                    NSString *first = strs[0];
                    NSString *last = strs[1];
                    
                    if (first.length<1) {
                        
                        first =@" ";
                    }
                    
                    if (last.length <1) {
                        
                        last = @" ";
                    }
                    
                    
                    textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
                } else {
                    textImage.textImageLabel.text = [display substringToIndex:2];
                }
            } else {
                if (display.length > 0) {
                    textImage.string = [display substringToIndex:1];
                }
            }
        }
        
        return contactCell;
    }
    
    self.tableView.clipsToBounds = YES;
    static NSString *cellID = @"Contactcell";
    ContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!contactCell) {
        contactCell = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil][0];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if([orderedSections count] > indexPath.section){
        
        contactCell.multipleSelectionBackgroundView = [[UIView alloc] init];
        
        NSMutableArray* values = [mContacts objectForKey: [orderedSections objectAtIndex:section]];
        Contact* contact = [values objectAtIndex:row];
        
        if(contact && contact.displayName.length > 0){
            contactCell.contactDisplayName.text = contact.displayName;
        }
        
        
        if (contact && contact.picture) {
            contactCell.contactIcon.image = [UIImage imageWithData:contact.picture];
        } else {
            contactCell.contactIcon.hidden = YES;
            TextImageView *textImage = [[TextImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
            textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:20];
            textImage.raduis = 20.0;
            [contactCell.contentView addSubview:textImage];
            
            if ([self includeChinese:contact.displayName]) {
                if (contact.displayName.length < 2) {
                    textImage.string = [contact.displayName substringToIndex:1];
                    return contactCell;
                }
                NSString *substring = [contact.displayName substringToIndex:2];
                if ([self includeChinese:substring]) {
                    textImage.string = [contact.displayName substringToIndex:1];
                    return contactCell;
                }
            }
            if ([contact.displayName length] >= 2) {
                
                NSString * tempstr = [contact.displayName substringFromIndex:contact.displayName.length-1];
                
                
                
                if ([contact.displayName containsString:@" "]  && ![tempstr isEqualToString:@" "] ) {
                    NSArray *strs = [contact.displayName componentsSeparatedByString:@" "];
                    
                    
                    NSString *first = strs[0];
                    
                    NSString *last = strs[1];
                    
                    if (first.length>0 && last.length>0  ) {
                        textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
                        
                    }
                    
                    
                } else {
                    textImage.textImageLabel.text = [contact.displayName substringToIndex:2];
                }
            } else {
                textImage.string = [contact.displayName substringToIndex:1];
            }
        }
        [contactCell layoutIfNeeded];
        
        return contactCell;
    }
    
    return cell;
}

- (BOOL)isChinese:(NSString *)predicateStr
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)includeChinese:(NSString *)predicateStr
{
    for(int i=0; i< [predicateStr length];i++)
    {
        int a =[predicateStr characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (self.mSearchDisplay.active) {
        return nil;
    }
    
    if(mSearching){
        return nil;
    }
    
    if (self.segment.selectedSegmentIndex == 1) {
        return nil;
    }
    
    return orderedSections;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == self.tableView) {
            [databaseManage removeFavorite:mFavoritersArray[indexPath.row]];
            [mFavoritersArray removeObjectAtIndex:indexPath.row];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UIView *)setUpFooterView {
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60.0)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    
    label.textColor = [UIColor lightGrayColor];
    return label;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(mLetUserSelectRow){
        return indexPath;
    }
    else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.tableView.isEditing) {
        if (self.segment.selectedSegmentIndex == 1) {
            if (sipFriends.count > indexPath.row) {
                [deleteAccounts addObject:sipFriends[indexPath.row]];
                [deleteIndexPaths addObject:indexPath];
                _deleteNum += 1;
            }
            
        } else {
            if (orderedSections.count > indexPath.section) {
                NSMutableArray* values = [mContacts objectForKey:[orderedSections objectAtIndex:indexPath.section]];
                [deleteAccounts addObject:[values objectAtIndex:indexPath.row]];
                [deleteIndexPaths addObject:indexPath];
                _deleteNum += 1;
            }
        }
        if (deleteButton) {
            //            [deleteButton setTitle:[NSString stringWithFormat:@"删除(%ld)",(long)_deleteNum] forState:UIControlStateNormal];
            
            NSString *temp = NSLocalizedString(@"Delete", @"Delete");
            
            [deleteButton setTitle:[NSString stringWithFormat:@"%@(%ld)",temp,(long)_deleteNum] forState:UIControlStateNormal];
            
        }
        
    }
    else {
        //*
        // Navigation logic may go here. Create and push another view controller.
        
        Contact* contact = nil;
        
        if (self.segment.selectedSegmentIndex == 0) { //localcontact
            if([orderedSections count] > indexPath.section){
                NSMutableArray* values = [mContacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
                //                NSLog(@"%@",indexPath);
                if (values.count >= indexPath.row) {
                    contact = [values objectAtIndex: indexPath.row];
                }
            }
        } else if (self.segment.selectedSegmentIndex == 1) { //sipFriends
            if(self.mSearchDisplay.active){
                contact = [mSearchResult objectAtIndex: indexPath.row];
            }
            if (sipbuttonindex ==0) {
                contact = [sipFriends objectAtIndex: indexPath.row];
            }else if(sipbuttonindex ==1){
                contact = [sipOnlineArr objectAtIndex: indexPath.row];
            }else
            {
                contact = [sipOfflineArr objectAtIndex: indexPath.row];
            }
        }else if([self.segment selectedSegmentIndex] == 2) { //favorite
            
            Favorite* favorite = [mFavoritersArray objectAtIndex:indexPath.row];
            
            NSLog(@"favorite.mFavoriteIdentifi = %@",favorite.mFavoriteIdentifi);
            
            //#ifdef __IPHONE_9_0
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            CNContact *cnContact = [contactStore unifiedContactWithIdentifier:favorite.mFavoriteIdentifi keysToFetch:@[CNContactIdentifierKey,CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactOrganizationNameKey, CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactSocialProfilesKey,CNContactPhoneNumbersKey,CNContactInstantMessageAddressesKey] error:nil];
            
            contact = [[Contact alloc] initWithCNContact:cnContact];
            
            //#else
            //                ABRecordRef person = ABAddressBookGetPersonWithRecordID(mAddressBook, favorite.mFavoriteId);
            //                contact = [[Contact alloc] initWithABRecordRef:person];
            //#endif
            
        }
        //        }
        
        if(contact && contact.displayName){
            UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            ContactDetailsViewController* contactDetails = [stryBoard instantiateViewControllerWithIdentifier:@"ContactDetails"];
            contactDetails.contact = contact;
            contactDetails.superControllerID = 2;
            contactDetails.superIndex = self.segment.selectedSegmentIndex;
            
            contactDetails.fromfirendlist =  _frommessage;
            
            contactDetails.imblock = ^(NSString *imstr) {
                
                contact.teststr = imstr;
                
                NSLog(@"contact.teststr================800===%@",contact.teststr);
            };
            
            
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contactDetails animated:YES];
            
            self.hidesBottomBarWhenPushed =NO;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segment.selectedSegmentIndex == 1) {
        [deleteAccounts removeObject:[sipFriends objectAtIndex:indexPath.row]];
        [deleteIndexPaths removeObject:indexPath];
        _deleteNum -= 1;
        
    } else {
        if (orderedSections.count > indexPath.section) {
            NSMutableArray* values = [mContacts objectForKey:[orderedSections objectAtIndex:indexPath.section]];
            [deleteAccounts removeObject:[values objectAtIndex:indexPath.row]];
            [deleteIndexPaths removeObject:indexPath];
            _deleteNum -= 1;
        }
    }
    if (deleteButton) {
        [deleteButton setTitle:[NSString stringWithFormat:@"%@(%ld)", NSLocalizedString(@"Delete", @"Delete"),(long)_deleteNum] forState:UIControlStateNormal];
    }
}


-(NSMutableArray*) contacts{
    return mAllContacts;
}


-(NSMutableArray*)getfavFriends{
    
    return  [databaseManage loadFavorites];
    
}

#pragma mark--

#pragma mark


-(NSMutableArray*)sipFriends {
    
    
    NSMutableArray *ferindarr = [[NSMutableArray alloc]init];
    
    [sipFriends removeAllObjects];
    
    [sipOnlineArr removeAllObjects];
    [sipOfflineArr removeAllObjects];
    
    //    for ( NSArray *temparr in  [mContacts allValues] ) {
    for (Contact *tempmyContact  in   mAllContacts) {
        if (tempmyContact.IMNumber  == nil  ||  [tempmyContact.IMNumber  isEqual:[NSNull null]]  ||  [tempmyContact.IMNumber  isEqualToString:@"None"]  || [tempmyContact.IMNumber  isEqualToString:@"从不"] ||  [tempmyContact.IMNumber  isEqualToString:@""] ) {
        }
        else
        {
            
            if ([tempmyContact.onlineState isEqualToString:NSLocalizedString(@"online", @"online")]) {
                [sipOnlineArr addObject:tempmyContact];
            }else{
                [sipOfflineArr addObject:tempmyContact];
            }
            [ferindarr addObject:tempmyContact];
        }
    }
    sipFriends = ferindarr;
    //    }
    
    return sipFriends;
}

-(NSDictionary*) numbers2ContactsMapper{
    return mNumbers2ContacstMapper;
}

-(NSArray*) contactsWithPredicate: (NSPredicate*)predicate{
    return [mAllContacts filteredArrayUsingPredicate: predicate];
}

-(Contact*) getContactByUri: (NSString*)uri{
    return nil;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    [mSearchResult removeAllObjects];
    mSearchResult = [NSMutableArray array];
    NSString* searchString = self.mSearchDisplay.searchBar.text;
    
    if (self.segment.selectedSegmentIndex == 0) {
        if(searchString == nil || [searchString isEqual:@""]) {
            [mSearchResult addObjectsFromArray:mAllContacts];
        }else{
            for (Contact* contact in mAllContacts)
            {
                if (contact && contact.displayName && [contact.displayName rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    [mSearchResult addObject:contact];
                }
            }
        }
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        NSMutableArray * dataSource;
        if (sipbuttonindex ==0) {
            dataSource = sipFriends;
        }else if(sipbuttonindex ==1){
            dataSource = sipOnlineArr;
        }else
        {
            dataSource = sipOfflineArr;
        }
        
        if(searchString == nil || [searchString isEqual:@""]) {
            [mSearchResult addObjectsFromArray:dataSource];
            
        }else{
            for (Contact* contact in dataSource)
            {
                NSString *display = [contact.displayName isEqualToString:@""] ? contact.firstName : contact.displayName;
                if (display && [display rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    [mSearchResult addObject:contact];
                }
            }
        }
    }
    [self refreshDataAndReload];
}

-(Contact*) getContactByPhoneNumber: (NSString*)phoneNumber{
    if(!mNumbers2ContacstMapper){
        mNumbers2ContacstMapper = [[NSMutableDictionary alloc] init];
    }
    //#ifdef __IPHONE_9_0
    [self syncLoadSystemContact];
    //#else
    //    [self syncLoad];
    //#endif
    
    if(!phoneNumber || ![mNumbers2ContacstMapper objectForKey:phoneNumber]){
        
        return nil;
    }
    return [mNumbers2ContacstMapper objectForKey:phoneNumber];
}

#pragma mark - addContactsButtonClicked
-(void)addContactsButtonClicked:(id)sender
{
    
    AddorEditViewController *ctr = [[AddorEditViewController alloc] init];
    ctr.recognizeID = 2555;
    ctr.segmentSelect = self.segment.selectedSegmentIndex;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:ctr];
    navc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navc animated:YES completion:nil];
}


#pragma mark - SeLectAllContactsClick
-(void)selectAllContactsButtonClick:(id)sender {
    _deleteNum = 0;
    [deleteIndexPaths removeAllObjects];
    [deleteAccounts removeAllObjects];
    if (self.segment.selectedSegmentIndex == 1) {
        for (int i = 0; i < sipFriends.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [deleteIndexPaths addObject:indexPath];
            [deleteAccounts addObject:sipFriends[i]];
            _deleteNum += 1;
        }
    } else {
        for (int i = 0; i < orderedSections.count; i++) {
            NSMutableArray* values = [mContacts objectForKey:[orderedSections objectAtIndex:i]];
            for (int j = 0; j < values.count; j ++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [deleteIndexPaths addObject:indexPath];
                [deleteAccounts addObject:[values objectAtIndex:j]];
                _deleteNum += 1;
            }
        }
    }
    if (deleteButton) {
        [deleteButton setTitle:[NSString stringWithFormat:@"%@(%ld)", NSLocalizedString(@"Delete", @"Delete"),(long)_deleteNum] forState:UIControlStateNormal];
    }
}

#pragma mark - selectContactsButtonClicked
-(void)selectContactsButtonClicked:(id)sender {
    
    _deleteNum = 0;
    UIBarButtonItem* buttonItem = (UIBarButtonItem *)sender;
    
    if (!_isSelect) {
        
        _isSelect = !_isSelect;
        [buttonItem setTitle:NSLocalizedString(@"Cancel", @"Cancel")];
        self.segment.hidden = YES;
        _bottomView = [self getBottomSelectionView];
        UIBarButtonItem* selectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select All", @"Select All") style:UIBarButtonItemStylePlain target:self action:@selector(selectAllContactsButtonClick:)];
        selectAll.tintColor = MAIN_COLOR;
        self.navigationItem.rightBarButtonItem = selectAll;
        
        [self.tableView setEditing:YES animated:YES];
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, _bottomView.bounds.size.height, 0);
        self.tableView.tableHeaderView=nil;
    } else {
        _isSelect = !_isSelect;
        [buttonItem setTitle:NSLocalizedString(@"Select", @"Select")];
        self.segment.hidden = NO;
        [_bottomView removeFromSuperview];
        self.navigationItem.rightBarButtonItem = _mAddContactsButton;
        
        [self.tableView setEditing:NO animated:YES];
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.tableHeaderView=self.mSearchDisplay.searchBar;
        [deleteAccounts removeAllObjects];
        [deleteIndexPaths removeAllObjects];
    }
    
}

-(UIView*)getBottomSelectionView {
    UIView* bottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - tabBarheight + 64 , self.view.bounds.size.width, 49)];
    BOOL isDark =false;
    if (@available(iOS 11.0, *)) {
        bottom.backgroundColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bottom.backgroundColor = [UIColor whiteColor];
    }
    
    [self.view.superview addSubview:bottom];
    [self.view.superview bringSubviewToFront:bottom];
    
    UIButton* message = [UIButton buttonWithType:UIButtonTypeSystem];
    message.frame = CGRectMake(20, 10, 60, 30);
    [message setTitle:NSLocalizedString(@"Message", @"Message") forState:UIControlStateNormal];
    [message setTintColor:[UIColor grayColor]];
    [message addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    message.tag = 000;
    //   [bottom addSubview:message];
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteButton.frame = CGRectMake(bottom.bounds.size.width - 100, 10, 80, 30);
    [deleteButton setTitle:NSLocalizedString(@"Delete", @"Delete") forState:UIControlStateNormal];
    [deleteButton setTintColor:[UIColor grayColor]];
    [deleteButton addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = 111;
    [bottom addSubview:deleteButton];
    
    return bottom;
}

-(void)bottomButtonClick:(id)sender {
    UIButton* btn = (UIButton *)sender;
    if (btn.tag == 000) {
        NSLog(@"短信。。。");
    } else {
        NSMutableArray* tempArr = [[NSMutableArray alloc] init];
        
        if (self.segment.selectedSegmentIndex == 1) {
            NSMutableArray *tempsipfriends = [[NSMutableArray alloc]initWithArray:sipFriends];
            
            for (Contact *sipf in tempsipfriends) {
                if ([deleteAccounts containsObject:sipf]) {
                    [self deletesip:sipf];
                    [sipFriends removeObject:sipf];
                }
            }
            
            [self syncLoadSystemContact];
            [self.tableView reloadData];
        } else {
            
            for (int i = 0; i < orderedSections.count; i ++) {
                NSMutableArray* values = [mContacts objectForKey:[orderedSections objectAtIndex:i]];
                for (Contact* value in values) {
                    if ([deleteAccounts containsObject:value]) {
                        [tempArr addObject:value];
                    }
                }
                [values removeObjectsInArray:tempArr];
                [mContacts setObject:values forKey:orderedSections[i]];
            }
            
        }
        
        if (_deleteNum != 0) {
            //#ifndef __IPHONE_9_0
            //            [self removeAddressBookContacts:tempArr];
            //#else
            [self removeCNContacts:tempArr];
            //#endif
            [self selectContactsButtonClicked:_mSelectButton];
            _deleteNum = 0;
        }
    }
}


-(void)editSipcontactDoneFromDetailViewController {
    //  [databaseManage loadSIPFriends];
    [self getSipFriendsDataSource];
    [self refreshDataAndReload];
}

-(void)editContactHasDoneFromDetailViewController {
    
    [self syncLoadSystemContact];
    [self refreshDataAndReload];
    
    [[AppDelegate sharedInstance].recentsViewController RefreshRecntCon];
    
    
}


#pragma mark -
#pragma mark
-(void)sendoncepresenceSubscribe{
    
    for (Contact * tact in  mAllContacts) {
        
        if (tact.IMNumber  == nil  ||  [tact .IMNumber  isEqual:[NSNull null]]  ||  [tact.IMNumber isEqualToString:@""]) {
            
            //    NSLog(@"no imnumber");
        }
        else
        {
            NSArray *strs =[tact.IMNumber componentsSeparatedByString:@"@"];
            [portSIPEngine presenceSubscribe:strs[0] subject:@"Available"];
        }
        
    }
    if(shareAppDelegate.portSIPHandle.mAccount.presenceAgent==1)
    {
        
        int fla = [portSIPEngine setPresenceStatus:-1 statusText:@"Available"];
        
    }
    else {
        
        for (Contact *friend in mAllContacts) {
            if (friend.subscribeID) {
                
                int  staus =     [portSIPEngine setPresenceStatus:friend.subscribeID statusText:@"Available"];
                
                NSLog(@"staus== %d",staus);
                NSLog(@" subscribeID== %ld",friend.subscribeID);
            }
            
        }
    }
    
}

#pragma mark -  PresenceState

-(void)onPresenceOnline:(NSString *)fromDisplayName from:(NSString *)from stateText:(NSString *)stateText {
    
    for (Contact *conta in mAllContacts) {
        if (conta) {
            NSString *str = from;
            if ([from containsString:@"sip:"]) {
                str = [   from substringFromIndex:4];
            }
            Account *count =     shareAppDelegate.portSIPHandle.mAccount;
            
            NSString *tempstr = conta.IMNumber;
            
            if ([tempstr isEqual:[NSNull null]]  || tempstr ==nil) {
                
                continue;
                
            }
            
            
            if  ([conta.IMNumber rangeOfString:@"@"].location ==NSNotFound){
                
                tempstr = [NSString stringWithFormat:@"%@@%@",conta.IMNumber,count.userDomain];
                
            }
            
            if ([str rangeOfString:tempstr].location !=NSNotFound) {
                conta.onlineState =  NSLocalizedString(@"online", @"online");
                
                if ([stateText isEqualToString:@""]) {
                    
                    stateText = @"Online";
                }
                conta.stateText = NSLocalizedString(stateText, stateText);
                
                
                if ([conta.stateText  isEqualToString:NSLocalizedString(@"offline", @"offline")]) {
                    
                    conta.onlineState = NSLocalizedString(@"offline", @"offline");
                    
                }
                if (self.segment.selectedSegmentIndex == 1) {
                    [self refreshData];
                }
                
                break;
                
                
            }
        }
    }
    
    [self pageTitleView:self.pageTitleView selectedIndex:sipbuttonindex];
}

- (void)onPresenceOffline:(NSString*)fromDisplayName from:(NSString*)from
{
    
    for (Contact *conta in mAllContacts) {
        if (conta) {
            NSString *str = from;
            if ([from containsString:@"sip:"]) {
                str = [from substringFromIndex:4];
            }
            
            Account *count =     shareAppDelegate.portSIPHandle.mAccount;
            NSString *tempstr = conta.IMNumber;
            
            if ([tempstr isEqual:[NSNull null]]  || tempstr ==nil) {
                continue;
            }
            
            if  ([conta.IMNumber rangeOfString:@"@"].location ==NSNotFound){
                
                tempstr = [NSString stringWithFormat:@"%@@%@",conta.IMNumber,count.userDomain];
                
            }
            
            if ([str rangeOfString:tempstr].location !=NSNotFound) {
                conta.onlineState = NSLocalizedString(@"offline", @"offline");
                conta.stateText = NSLocalizedString(@"offline", @"offline");
                if (self.segment.selectedSegmentIndex == 1) {
                    
                    [self refreshDataAndReload];
                    if(_mSearchDisplay.active){
                        NSString* textback = _mSearchDisplay.searchBar.text;
                        _mSearchDisplay.searchBar.text = @"";
                        _mSearchDisplay.searchBar.text = textback;
                    }
                }
                break;
            }
        }
    }
    
    [self pageTitleView:self.pageTitleView selectedIndex:sipbuttonindex];
    
}

- (void)onSubscriptionFailure:(long)subscribeId
                   statusCode:(int)statusCode {
    
    NSLog(@"onSubscriptionFailure");
    
}


- (void)onPresenceRecvSubscribe:(long)subscribeId
                fromDisplayName:(NSString *)fromDisplayName
                           from:(NSString *)from
                        subject:(NSString *)subject{
    
    NSLog(@"onPresenceRecvSubscribe from:%@ subscribeld=%ld", from,subscribeId );
    
    
    
    for (Contact *sipf in mAllContacts) {
        if ([sipf.IMNumber isEqualToString:from]) {
            //has exist this contact
            //update subscribedId
            sipf.subscribeID = subscribeId;
            
            [portSIPEngine presenceAcceptSubscribe:subscribeId];
            [portSIPEngine setPresenceStatus:subscribeId statusText:@"Available"];
            
            if([[self getCurrentTimestamp] integerValue]- sipf.outSubscribeId > 60000){
                
                sipf.outSubscribeId =[[self getCurrentTimestamp] integerValue];
                [portSIPEngine presenceSubscribe:sipf.IMNumber subject:@"Available"];
                
                return;
            }
        }
    }
}

-(NSString*)getCurrentTimestamp{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

@end
