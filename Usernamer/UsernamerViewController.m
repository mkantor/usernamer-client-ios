//
//  UsernamerViewController.m
//  Usernamer
//
//  Created by Matt Kantor on 6/25/13.
//  Copyright (c) 2013 Matt Kantor. All rights reserved.
//

#import "UsernamerViewController.h"

@interface UsernamerViewController ()

@end

@implementation UsernamerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Submit a user to the server and handle the response.
 */
- (IBAction)submitUser:(id)sender {
    self.username = self.usernameField.text;

    // TODO: Move this to a global configuration getter?
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
    NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:path];

    NSURL *url = [NSURL URLWithString:[configuration objectForKey:@"Server URL"]];

    // TODO? Maybe move some of this to a helper function?
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    // TODO: Also send deviceType and deviceId (or use UA string or somesuch).
    NSString *formData = [NSString stringWithFormat:@"username=%@", self.username];
    [request setHTTPBody:[formData dataUsingEncoding:NSUTF8StringEncoding]];

    [NSURLConnection connectionWithRequest:request delegate:self];
}

/**
 * Handle return keypresses.
 */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.usernameField) {
        // Hide the username field when the user hits return.
        [theTextField resignFirstResponder];
    }
    return YES;
}

/**
 * Handle successful HTTP responses.
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // TODO: Change based on server response. Could either have the server
    // respond with an appropriate message and just insert it here, or maybe
    // have different cases for status codes and have the client determine the
    // message.
    // I'm leaning towards just sending messages from the server. It's less
    // duplication and provides the ability to change business logic in the 
    // future without altering the client.
    self.resultLabel.text = @"Great success!";
}

/**
 * Handle unsuccessful HTTP responses.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // TODO: Change message based on details of the error.
    self.resultLabel.text = @"Something went wrong!";
}
@end
