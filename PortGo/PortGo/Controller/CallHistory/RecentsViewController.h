//
//  RecentsViewController.h
//  PortGo
//
//  Created by Joe Lepple on 3/26/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "DataBaseManage.h"
#import "History.h"
#import <AddressBookUI/AddressBookUI.h>

@interface RecentsViewController : UITableViewController<UIActionSheetDelegate,ABUnknownPersonViewControllerDelegate,ABPersonViewControllerDelegate>{
    
    int mStatusFilter;
    NSInteger  showindex;
    
    NSMutableArray *mHistoryArray;
    NSMutableArray * showHistoryArray;
    NSMutableDictionary *historys ;
    NSMutableArray *selectIndexs;
    
    NSInteger  lastListCount;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic)  UIBarButtonItem *editItem;

@property (nonatomic, strong) UIBarButtonItem *selectAllItem;
@property (nonatomic, strong) UIBarButtonItem *doneItem;
@property (nonatomic, strong) UIBarButtonItem *clearOptions;

- (IBAction) segmentIndexClicked: (id)sender;
- (void)addNewHistroy:(History*) addHistory;
- (void)cleanBadges;
-(NSArray *)getHistorys;
-(void)RefreshRecntCon;
@end
