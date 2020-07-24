//
//  NetworkTranportViewController.h
//  telephony
//
//  Created by World on 12/15/11.
//  Copyright 2011 HaveSoft Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "constatnts.h"

@protocol NetworkTranportViewControllerDelegate <NSObject>
- (void)didSelectTranport:(NSString *)tranport;
@end

@interface NetworkTranportViewController : UITableViewController{
    
    NSArray *list;
    NSString *lastSelectTranport;
}

@property (nonatomic, retain) NSArray *list;
@property (nonatomic, retain) NSString *lastSelectTranport;

@property (nonatomic, weak) id <NetworkTranportViewControllerDelegate> delegate;
@end
