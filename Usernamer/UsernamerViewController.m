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

    NSURL *url = [NSURL URLWithString:[configuration objectForKey:@"API Endpoint"]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    // Ask for a plaintext response.
    [request setValue:@"text/plain" forHTTPHeaderField:@"Accept"];

    // TODO: Also send deviceType and deviceId (or use UA string or somesuch).
    NSString *formData = [NSString stringWithFormat:@"username=%@", self.username];
    [request setHTTPBody:[formData dataUsingEncoding:NSUTF8StringEncoding]];

    [NSURLConnection connectionWithRequest:request delegate:self];

    // Initialize the property that will hold the response data.
    self.httpResponseBody = [[NSMutableData alloc] init];
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
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    self.httpResponseStatus = [response statusCode];
    self.httpResponseContentType = [response MIMEType];

    // Documentation says we should discard all previously received content here.
    // https://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSURLConnectionDelegate_Protocol/Reference/Reference.html
    [self.httpResponseBody setLength:0];
}

/**
 * Handle unsuccessful HTTP responses.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.resultLabel.text = error.localizedDescription;
    [self resetResponseData];
}

/**
 * Handle incoming HTTP response data. This is called multiple times as chunks 
 * of response come are received.
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.httpResponseBody appendData:data];
}

/**
 * Response has been completely received; time to display it.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *message;
    // If httpResponseBody is not empty, use it. Otherwise come up with a
    // message based on the httpResponseStatus.
    if([self.httpResponseBody length] > 0 && [self.httpResponseContentType isEqualToString:@"text/plain"]) {
        message = [[NSString alloc] initWithData:self.httpResponseBody encoding:NSUTF8StringEncoding];
        // Just use the first line.
        message = [[message componentsSeparatedByString: @"\n"] objectAtIndex:0];
    } else if(self.httpResponseStatus != 0) {
        // For some reason NSHTTPURLResponse wants to call 200 "no error",
        // which sucks.
        if(self.httpResponseStatus == 200) {
            message = @"ok";
        } else {
            message = [NSHTTPURLResponse localizedStringForStatusCode:self.httpResponseStatus];
        }

        message = [self capitalizeFirstLetter:message];
    } else {
        message = @"Unknown result";
    }

    self.resultLabel.text = message;

    [self resetResponseData];
}

- (void)resetResponseData {
    [self.httpResponseBody setLength:0];
    self.httpResponseStatus = 0;
    self.httpResponseContentType = nil;
}

- (NSString *)capitalizeFirstLetter:(NSString *)string {
    return [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
}
@end
