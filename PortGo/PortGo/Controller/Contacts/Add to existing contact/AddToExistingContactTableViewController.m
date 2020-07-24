//
//  AddToExistingContactTableViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/12/7.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "AddToExistingContactTableViewController.h"
#import "ContactCell.h"
#import "AppDelegate.h"
#import "UIColor_Hex.h"
#import "TextImageView.h"
#import "AddorEditViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>
#import "Contact.h"
#import "AddorEditViewController.h"


@interface AddToExistingContactTableViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate, UISearchResultsUpdating>
{
    NSArray * mAllContacts;
    
    NSMutableArray* orderedSections;
    NSMutableDictionary* mContacts;
    NSMutableArray *mSearchResult;
    
    BOOL mSearching;
}

@property(strong, nonatomic) UISearchController *mSearchDisplay;

@end

@implementation AddToExistingContactTableViewController

-(void) initContacts{
    
    if(!mAllContacts){
        mAllContacts = [[NSMutableArray alloc] init];
    }
    
    
    if(!mContacts){
        mContacts = [[NSMutableDictionary alloc] init];
    }
    
    if(!orderedSections){
        orderedSections = [[NSMutableArray alloc] init];
    }
    
    if(!mSearchResult){
        mSearchResult = [[NSMutableArray alloc] init];
    }
    
    
    
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor,*bkColorLight;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
        bkColor = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColor = [UIColor whiteColor];
        bkColorLight = [UIColor lightGrayColor];
    }
    
    self.tableView.tableHeaderView.backgroundColor=bkColor;
    if (@available(iOS 13.0, *)) {
        _mSearchDisplay.searchBar.barTintColor = bkColor;
        _mSearchDisplay.searchBar.searchTextField.backgroundColor = bkColorLight;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self traitCollectionDidChange:self.traitCollection];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.mSearchDisplay dismissViewControllerAnimated:false completion:nil];
}

-(void)huishangye{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(huishangye) name:@"existinghuishangye" object:nil];
    
    self.title = @"选择联系人";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 50, MAIN_SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    
    
    self.mSearchDisplay = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.mSearchDisplay.searchResultsUpdater = self;
    self.mSearchDisplay.delegate = self;
    self.mSearchDisplay.definesPresentationContext = true;
    self.mSearchDisplay.dimsBackgroundDuringPresentation = false;
    self.mSearchDisplay.searchBar.placeholder = NSLocalizedString(@"Search Contact", @"Search Contact");
    self.definesPresentationContext = YES;
    self.tableView.sectionHeaderHeight = 30 ;
    self.tableView.tableHeaderView =self.mSearchDisplay.searchBar;
    [self.tableView setEditing:NO animated:YES];
    
    mSearching = NO;
    [self initContacts];
    
    mAllContacts = [contactView contacts];
    
    NSMutableArray * temparr = [[NSMutableArray alloc]initWithArray:mAllContacts];
    
    [self allDataRangerwithArry:temparr];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if(@available(iOS 11.0, *)){
        
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(20,0, 0, 0); //IEdgeInsetsZero;
        [self.tableView layoutIfNeeded];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    
    for (Contact* contact in arr) {
        NSString *dispalyName = contact.displayName;
        if (dispalyName) {
            NSInteger sectionNumber = [collation sectionForObject:dispalyName collationStringSelector:@selector(self)];
            NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
            [sectionNames addObject:contact];
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
    [self.tableView reloadData];
}

#pragma mark - Table view data source


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30.0)];
    sectionView.backgroundColor = [UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 30)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    
    titleLabel.text = orderedSections[section];
    [sectionView addSubview:titleLabel];
    
    sectionView.tag = 100 + section;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 29.5, self.tableView.bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
    [sectionView addSubview:line];
    
    return sectionView;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return orderedSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (orderedSections.count > section) {
        NSMutableArray *value = [mContacts objectForKey:[orderedSections objectAtIndex:section]];
        
        return [value count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
                    
                    
                    if (first.length<1) {
                        
                        first =@" ";
                    }
                    
                    if (last.length <1) {
                        
                        last = @" ";
                    }
                    
                    textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
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
    
    return nil;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact* contact = nil;
    
    if([orderedSections count] > indexPath.section){
        NSMutableArray* values = [mContacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
        //                NSLog(@"%@",indexPath);
        if (values.count >= indexPath.row) {
            contact = [values objectAtIndex: indexPath.row];
        }
    }
    
    AddorEditViewController *edit = [[AddorEditViewController alloc] initWithNibName:@"AddorEditViewController" bundle:nil];
    edit.modalPresentationStyle = UIModalPresentationFullScreen;
    edit.aContact = contact;
    edit.recognizeID = 2333;
    edit.addvoidcall = self.addvoidcall0;
    [edit didContactEditedCallback:^(Contact *returnContact) {  }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:edit];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#pragma mark - UISearchController Delegate Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [mSearchResult removeAllObjects];
    mSearchResult = [NSMutableArray array];
    NSString* searchString = self.mSearchDisplay.searchBar.text;
    if (searchString == nil || [searchString isEqual:@""]) {
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
    [self allDataRangerwithArry:mSearchResult];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.mSearchDisplay.active) {
        return nil;
    }
    
    if(mSearching){
        return nil;
    }
    return orderedSections;
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
@end
