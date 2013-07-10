//
//  UsernamerViewController.h
//  Usernamer
//
//  Created by Matt Kantor on 6/25/13.
//  Copyright (c) 2013 Matt Kantor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsernamerViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (copy, nonatomic) NSString *username;
@property (assign, nonatomic) NSInteger httpResponseStatus;
@property (copy, nonatomic) NSString *httpResponseContentType;
@property (strong, nonatomic) NSMutableData *httpResponseBody;
- (IBAction)submitUser:(id)sender;

@end