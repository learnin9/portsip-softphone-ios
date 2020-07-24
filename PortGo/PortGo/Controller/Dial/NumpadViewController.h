//
//  FirstViewController.h
//  PortGo
//
//  Created by Joe Lepple on 3/25/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "URLAsyncGet.h"
#import "PortSIPHandle.h"

@interface NumpadViewController : UIViewController<UITextFieldDelegate,UITextInputTraits,URLAsyncGetDelegate> {
    
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *returnCallButton;
- (void)onRegisterSuccess:(int)statusCode withStatusText:(char*) statusText;
- (void)onRegisterFailure:(int)statusCode withStatusText:(char*) statusText;
- (void)refreshReturnButtonState;
- (void)getBalance;
@property (weak, nonatomic) IBOutlet UIButton *callfowardbutton;
- (IBAction)callforward:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *nodisturbebutton;

- (IBAction)nodisture:(id)sender;

@end
