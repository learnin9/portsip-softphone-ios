//
//  ContactViewController.h
//  PortGo
//
//  Created by Joe Lepple on 4/8/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>
#import "Contact.h"
#import "ContactDetailsViewController.h"
#import "AddorEditViewController.h"


#import "SGPagingView.h"

//ABPeoplePickerNavigationControllerDelegate,ABPersonViewControllerDelegate,
@interface ContactViewController : UITableViewController<UISearchControllerDelegate, UISearchResultsUpdating,ABNewPersonViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate,SGPageTitleViewDelegate,SGPageContentViewDelegate>{
    NSMutableDictionary *mNumbers2ContacstMapper;
#if TARGET_OS_IPHONE
    ABAddressBookRef mAddressBook;
#elif TARGET_OS_MAC
#endif
    
    NSMutableArray* mAllContacts;
    NSMutableDictionary* mContacts;
    NSMutableArray* orderedSections;
    NSMutableArray *sipFriends;
    
    
    NSMutableArray * sipOnlineArr;
    NSMutableArray * sipOfflineArr;
    NSMutableArray *mFavoritersArray;
    NSMutableArray *mSearchResult;
    NSMutableArray* deleteAccounts;
    NSMutableArray* deleteIndexPaths;
    NSInteger  sipbuttonindex;
    
    UILabel* _footerLabel;
    
    UIView *viewToolbar;
    BOOL mSearching;
    BOOL mLetUserSelectRow;
    NSMutableArray *sipFriend_;
    
    ContactDetailsViewController* mContactDetailsController;
}

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
//@property(nonatomic,retain) UISearchBar *mSearchBarNew;

@property  BOOL frommessage;

@property(strong, nonatomic) UISearchController *mSearchDisplay;
@property(weak, nonatomic) IBOutlet UISegmentedControl *segment;

-(NSMutableArray*)getfavFriends;

-(NSMutableArray*) contacts;
-(NSArray*) sipFriends;
-(NSDictionary*) numbers2ContactsMapper;
-(NSArray*) contactsWithPredicate:(NSPredicate*)predicate;
-(Contact*) getContactByUri:(NSString*)uri;
-(Contact*) getContactByPhoneNumber:(NSString*)phoneNumber;

- (IBAction)addContactsButtonClicked: (id)sender;
-(void)syncLoad;
-(void)syncLoadSystemContact;
-(void)getSipFriendsDataSource;
-(void)editContactHasDoneFromDetailViewController;
-(void)editSipcontactDoneFromDetailViewController;
-(void)initAllContacts;
//-(NSArray *)allNumbers;
-(NSMutableArray *)getSipContacts;
-(NSMutableArray *)getSipFriendsAndContacts;

-(void)addSipContacts:(Contact *)sipfriend;
-(void)editSipContacts:(Contact *)sipfriend;

-(void)onPresenceOnline:(NSString *)fromDisplayName from:(NSString *)from stateText:(NSString *)stateText;

- (void)onPresenceOffline:(NSString*)fromDisplayName from:(NSString*)from;

- (void)onSubscriptionFailure:(long)subscribeId
                   statusCode:(int)statusCode;

-(void)sendoncepresenceSubscribe;
//-(void) initContacts;

- (void)onPresenceRecvSubscribe:(long)subscribeId
                fromDisplayName:(NSString *)fromDisplayName
                           from:(NSString *)from
                        subject:(NSString *)subject;

@end
