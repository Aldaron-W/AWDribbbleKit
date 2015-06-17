// MVDribbbleKit.m
//
// Copyright (c) 2014-2015 Marcel Voss
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MVDribbbleKit.h"

#import <SSKeychain/SSKeychain.h>
#import "ISO8601DateFormatter.h"

@interface MVDribbbleKit (Private)

// Retrieve access token from keychain
- (NSString *)retrieveToken;

// Used for retrieving resources.
- (void)GETOperationWithURL:(NSString *)url parameters:(NSDictionary *)parameters
                        success:(void (^) (NSDictionary *results, NSHTTPURLResponse *response))success
                        failure:(void (^) (NSError *error, NSHTTPURLResponse *response))failure;

// Used for updating resources, or performing custom actions.
- (void)PUTOperationWithURL:(NSString *)url parameters:(NSDictionary *)parameters
                     success:(void (^) (NSDictionary *results, NSHTTPURLResponse *response))success
                     failure:(void (^) (NSError *error, NSHTTPURLResponse *response))failure;

// Used for creating resources.
- (void)POSTOperationWithURL:(NSString *)url parameters:(NSDictionary *)parameters
                     success:(void (^) (NSDictionary *results, NSHTTPURLResponse *response))success
                     failure:(void (^) (NSError *error, NSHTTPURLResponse *response))failure;

// Used for deleting resources.
- (void)DELETEOperationWithURL:(NSString *)url parameters:(NSDictionary *)parameters
                       success:(void (^) (NSHTTPURLResponse *response))success
                       failure:(void (^) (NSError *error, NSHTTPURLResponse *response))failure;

@end

@implementation MVDribbbleKit

#pragma mark - Miscellaneous

- (instancetype)initWithClientID:(NSString *)clientID secretID:(NSString *)secretID callbackURL:(NSString *)callbackURL
{
    self = [super init];
    if (self) {
        _clientID = clientID;
        _clientSecret = secretID;
        _callbackURL = callbackURL;
    }
    return self;
}

+ (MVDribbbleKit *)sharedManager
{
    static MVDribbbleKit *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MVDribbbleKit new];
        instance.itemsPerPage = @30;
    });
    return instance;
}

#pragma mark - Authorization

- (MVAuthBrowser *)authorizeWithCompletion:(void (^)(NSError *, BOOL))completion
{
    // GET /oauth/authorize
    // GET https://dribbble.com/oauth/authorize
    
    NSMutableString *urlString;
    
    // Create a scopes string
    if (_scopes == nil) {
        
        // If the _scopes array is empty, it'll automatically use all four scopes
        urlString = [NSMutableString stringWithFormat:@"%@/oauth/authorize?client_id=%@&scope=write+upload+public+comment", kBaseURL, _clientID];
        
    } else {
        NSMutableString *tempString = [NSMutableString stringWithFormat:@"%@/oauth/authorize?client_id=%@&scope=", kBaseURL, _clientID];
        
        for (NSString *scope in _scopes) {
            if (_scopes.lastObject == scope) {
                [tempString appendString:scope];
            } else {
                NSString *string = [NSString stringWithFormat:@"%@+", scope];
                [tempString appendString:string];
            }
            
        }
        urlString = tempString;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];

    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *controller = window.rootViewController;
    
    MVAuthBrowser *authBrowser = [[MVAuthBrowser alloc] initWithURL:url];
    authBrowser.callbackURL = [NSURL URLWithString:_callbackURL];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:authBrowser];
//    
//    [controller presentViewController:navController animated:YES completion:nil];
    
    authBrowser.completionHandler = ^(NSURL *url, NSError *error) {
        if (error == nil) {
            // POST /oauth/token
            // https://dribbble.com/oauth/token
            
            NSString *urlString = [NSString stringWithFormat:@"%@/oauth/token", kBaseURL];
            
            // Extract the temporary code
            NSString *codeString = [[url query] stringByReplacingOccurrencesOfString:@"code=" withString:@""];
            
            // Exchange the temporary code for an access token
            [self POSTOperationWithURL:urlString parameters:@{@"client_id": _clientID, @"client_secret": _clientSecret, @"code": codeString} success:^(NSDictionary *results, NSHTTPURLResponse *response) {
                
                NSString *accessToken = results[@"access_token"];
                
                NSError *keychainError = nil;
                [SSKeychain setPassword:accessToken forService:kDribbbbleKeychainService
                                account:kDribbbleAccountName error:&keychainError];
                
                if (keychainError) {
                    completion(nil, NO);
                } else {
                    completion(nil, YES);
                }
                
            } failure:^(NSError *error, NSHTTPURLResponse *response) {
                completion(error, NO);
            }];
        } else {
            completion(error, NO);
        }
    };
    
    return authBrowser;
}

- (void)setClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret callbackURL:(NSString *)callbackURL
{
    _clientID = clientID;
    _clientSecret = clientSecret;
    _callbackURL = callbackURL;
}

- (BOOL)isAuthorized
{
    if ([SSKeychain accountsForService:kDribbbbleKeychainService]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)removeAccount
{
    if ([SSKeychain accountsForService:kDribbbbleKeychainService]) {
        NSString *accountUsername = [[SSKeychain accountsForService:kDribbbbleKeychainService][0]
                                     valueForKey:kSSKeychainAccountKey];
        
        NSError *deletionError = nil;
        [SSKeychain deletePasswordForService:kDribbbbleKeychainService account:accountUsername
                                       error:&deletionError];
        
        if (deletionError) {
            NSLog(@"Couldn't delete token");
        }
    }
}


@end