//Copyright (c) 2014-2020 AgileBits Inc.
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#ifdef __IPHONE_8_0
#import <WebKit/WebKit.h>
#endif

#if __has_feature(nullability)
NS_ASSUME_NONNULL_BEGIN
#else
#define nullable
#define __nullable
#define nonnull
#define __nonnull
#endif

// Login Dictionary keys - Used to get or set the properties of a 1Password Login

FOUNDATION_EXPORT NSString *const AppExtensionURLStringKey;
FOUNDATION_EXPORT NSString *const AppExtensionUsernameKey;
FOUNDATION_EXPORT NSString *const AppExtensionPasswordKey;
FOUNDATION_EXPORT NSString *const AppExtensionTOTPKey;
FOUNDATION_EXPORT NSString *const AppExtensionTitleKey;
FOUNDATION_EXPORT NSString *const AppExtensionNotesKey;
FOUNDATION_EXPORT NSString *const AppExtensionSectionTitleKey;
FOUNDATION_EXPORT NSString *const AppExtensionFieldsKey;
FOUNDATION_EXPORT NSString *const AppExtensionReturnedFieldsKey;
FOUNDATION_EXPORT NSString *const AppExtensionOldPasswordKey;
FOUNDATION_EXPORT NSString *const AppExtensionPasswordGeneratorOptionsKey;

// Password Generator options - Used to set the 1Password Password Generator options when saving a new Login or when changing the password for for an existing Login
FOUNDATION_EXPORT NSString *const AppExtensionGeneratedPasswordMinLengthKey;
FOUNDATION_EXPORT NSString *const AppExtensionGeneratedPasswordMaxLengthKey;
FOUNDATION_EXPORT NSString *const AppExtensionGeneratedPasswordRequireDigitsKey;
FOUNDATION_EXPORT NSString *const AppExtensionGeneratedPasswordRequireSymbolsKey;
FOUNDATION_EXPORT NSString *const AppExtensionGeneratedPasswordForbiddenCharactersKey;

// Errors codes
FOUNDATION_EXPORT NSString *const AppExtensionErrorDomain;

FOUNDATION_EXPORT NS_ENUM(NSUInteger, AppExtensionErrorCode) {
    AppExtensionErrorCodeCancelledByUser                    = 0,
    AppExtensionErrorCodeAPINotAvailable                    = 1,
    AppExtensionErrorCodeFailedToContactExtension           = 2,
    AppExtensionErrorCodeFailedToLoadItemProviderData       = 3,
    AppExtensionErrorCodeCollectFieldsScriptFailed          = 4,
    AppExtensionErrorCodeFillFieldsScriptFailed             = 5,
    AppExtensionErrorCodeUnexpectedData                     = 6,
    AppExtensionErrorCodeFailedToObtainURLStringFromWebView = 7
};

// Note to creators of libraries or frameworks:
// If you include this code within your library, then to prevent potential duplicate symbol
// conflicts for adopters of your library, you should rename the OnePasswordExtension class
// and associated typedefs. You might to so by adding your own project prefix, e.g.,
// MyLibraryOnePasswordExtension.

typedef void (^OnePasswordLoginDictionaryCompletionBlock)(NSDictionary * __nullable loginDictionary, NSError * __nullable error);
typedef void (^OnePasswordSuccessCompletionBlock)(BOOL success, NSError * __nullable error);
typedef void (^OnePasswordExtensionItemCompletionBlock)(NSExtensionItem * __nullable extensionItem, NSError * __nullable error);

@interface OnePasswordExtension : NSObject

+ (OnePasswordExtension *)sharedExtension;

/*!
 @discussion Determines if the 1Password Extension is available. Allows you to only show the 1Password login button to those
 that can use it. Of course, you could leave the button enabled and educate users about the virtues of strong, unique
 passwords instead :)
 
 @return isAppExtensionAvailable Returns YES if any app that supports the generic `org-appextension-feature-password-management` feature is installed on the device.
 */
#ifdef __IPHONE_8_0
- (BOOL)isAppExtensionAvailable NS_EXTENSION_UNAVAILABLE_IOS("Not available in an extension. Check if org-appextension-feature-password-management:// URL can be opened by the app.");
#else
- (BOOL)isAppExtensionAvailable;
#endif

/*!
 Called from your login page, this method will find all available logins for the given URLString.
 
 @discussion 1Password will show all matching Login for the naked domain of the given URLString. For example if the user has an item in your 1Password vault with "subdomain1.domain.com” as the website and another one with "subdomain2.domain.com”, and the URLString is "https://domain.com", 1Password will show both items.
 
 However, if no matching login is found for "https://domain.com", the 1Password Extension will display the "Show all Logins" button so that the user can search among all the Logins in the vault. This is especially useful when the user has a login for "https://olddomain.com".
 
 After the user selects a login, it is stored into an NSDictionary and given to your completion handler. Use the `Login Dictionary keys` above to
 extract the needed information and update your UI. The completion block is guaranteed to be called on the main thread.
 
 @param URLString For the matching Logins in the 1Password vault.
 
 @param viewController The view controller from which the 1Password Extension is invoked. Usually `self`
 
 @param sender The sender which triggers the share sheet to show. UIButton, UIBarButtonItem or UIView. Can also be nil on iPhone, but not on iPad.
 
 @param completion A completion block called with two parameters loginDictionary and error once completed. The loginDictionary reply parameter that contains the username, password and the One-Time Password if available. The error Reply parameter that is nil if the 1Password Extension has been successfully completed, or it contains error information about the completion failure.
 */
- (void)findLoginForURLString:(nonnull NSString *)URLString forViewController:(nonnull UIViewController *)viewController sender:(nullable id)sender completion:(nonnull OnePasswordLoginDictionaryCompletionBlock)completion;

/*!
 Create a new login within 1Password and allow the user to generate a new password before saving.
 
 @discussion The provided URLString should be unique to your app or service and be identical to what you pass into the find login method.
 The completion block is guaranteed to be called on the main
 thread.
 
 @param URLString For the new Login to be saved in 1Password.
 
 @param loginDetailsDictionary about the Login to be saved, including custom fields, are stored in an dictionary and given to the 1Password Extension.
 
 @param passwordGenerationOptions The Password generator options represented in a dictionary form.
 
 @param viewController The view controller from which the 1Password Extension is invoked. Usually `self`
 
 @param sender The sender which triggers the share sheet to show. UIButton, UIBarButtonItem or UIView. Can also be nil on iPhone, but not on iPad.
 
 @param completion A completion block which is called with type parameters loginDictionary and error. The loginDictionary reply parameter which contain all the information about the newly saved Login. Use the `Login Dictionary keys` above to extract the needed information and update your UI. For example, updating the UI with the newly generated password lets the user know their action was successful. The error reply parameter that is nil if the 1Password Extension has been successfully completed, or it contains error information about the completion failure.
 */
- (void)storeLoginForURLString:(nonnull NSString *)URLString loginDetails:(nullable NSDictionary *)loginDetailsDictionary passwordGenerationOptions:(nullable NSDictionary *)passwordGenerationOptions forViewController:(nonnull UIViewController *)viewController sender:(nullable id)sender completion:(nonnull OnePasswordLoginDictionaryCompletionBlock)completion;

/*!
 Change the password for an existing login within 1Password.
 
 @discussion The provided URLString should be unique to your app or service and be identical to what you pass into the find login method. The completion block is guaranteed to be called on the main thread.
 
 1Password 6 and later:
 The 1Password Extension will display all available the matching Logins for the given URL string. The user can choose which Login item to update. The "New Login" button will also be available at all times, in case the user wishes to to create a new Login instead,
 
 1Password 5:
 These are the three scenarios that are supported:
 1. A single matching Login is found: 1Password will enter edit mode for that Login and will update its password using the value for AppExtensionPasswordKey.
 2. More than a one matching Logins are found: 1Password will display a list of all matching Logins. The user must choose which one to update. Once in edit mode, the Login will be updated with the new password.
 3. No matching login is found: 1Password will create a new Login using the optional fields if available to populate its properties.
 
 @param URLString for the Login to be updated with a new password in 1Password.
 
 @param loginDetailsDictionary about the Login to be saved, including old password and the username, are stored in an dictionary and given to the 1Password Extension.
 
 @param passwordGenerationOptions The Password generator options epresented in a dictionary form.
 
 @param viewController The view controller from which the 1Password Extension is invoked. Usually `self`
 
 @param sender The sender which triggers the share sheet to show. UIButton, UIBarButtonItem or UIView. Can also be nil on iPhone, but not on iPad.
 
 @param completion A completion block which is called with type parameters loginDictionary and error. The loginDictionary reply parameter which contain all the information about the newly updated Login, including the newly generated and the old password. Use the `Login Dictionary keys` above to extract the needed information and update your UI. For example, updating the UI with the newly generated password lets the user know their action was successful. The error reply parameter that is nil if the 1Password Extension has been successfully completed, or it contains error information about the completion failure.
 */
- (void)changePasswordForLoginForURLString:(nonnull NSString *)URLString loginDetails:(nullable NSDictionary *)loginDetailsDictionary passwordGenerationOptions:(nullable NSDictionary *)passwordGenerationOptions forViewController:(UIViewController *)viewController sender:(nullable id)sender completion:(nonnull OnePasswordLoginDictionaryCompletionBlock)completion;

/*!
 Called from your web view controller, this method will show all the saved logins for the active page in the provided web
 view, and automatically fill the HTML form fields. Supports WKWebView.
 
 @discussion 1Password will show all matching Login for the naked domain of the current website. For example if the user has an item in your 1Password vault with "subdomain1.domain.com” as the website and another one with "subdomain2.domain.com”, and the current website is "https://domain.com", 1Password will show both items.
 
 However, if no matching login is found for "https://domain.com", the 1Password Extension will display the "New Login" button so that the user can create a new Login for the current website.
 
 @param webView The web view which displays the form to be filled. The active WKWebView. Must not be nil.
 
 @param viewController The view controller from which the 1Password Extension is invoked. Usually `self`
 
 @param sender The sender which triggers the share sheet to show. UIButton, UIBarButtonItem or UIView. Can also be nil on iPhone, but not on iPad.
 
 @param yesOrNo Boolean flag. If YES is passed only matching Login items will be shown, otherwise the 1Password Extension will also display Credit Cards and Identities.
 
 @param completion Completion block called on completion with parameters success, and error. The success reply parameter that is YES if the 1Password Extension has been successfully completed or NO otherwise. The error reply parameter that is nil if the 1Password Extension has been successfully completed, or it contains error information about the completion failure.
 */
- (void)fillItemIntoWebView:(nonnull WKWebView *)webView forViewController:(nonnull UIViewController *)viewController sender:(nullable id)sender showOnlyLogins:(BOOL)yesOrNo completion:(nonnull OnePasswordSuccessCompletionBlock)completion;

/*!
 Called in the UIActivityViewController completion block to find out whether or not the user selected the 1Password Extension activity.
 
 @param activityType or the bundle identidier of the selected activity in the share sheet.
 
 @return isOnePasswordExtensionActivityType Returns YES if the selected activity is the 1Password extension, NO otherwise.
 */
- (BOOL)isOnePasswordExtensionActivityType:(nullable NSString *)activityType;

/*!
 The returned NSExtensionItem can be used to create your own UIActivityViewController. Use `isOnePasswordExtensionActivityType:` and `fillReturnedItems:intoWebView:completion:` in the activity view controller completion block to process the result. The completion block is guaranteed to be called on the main thread.
 
 @param webView The web view which displays the form to be filled. The active WKWebView. Must not be nil.
 
 @param completion Completion block called on completion with extensionItem and error. The extensionItem reply parameter that is contains all the info required by the 1Password extension if has been successfully completed or nil otherwise. The error reply parameter that is nil if the 1Password extension item has been successfully created, or it contains error information about the completion failure.
 */
- (void)createExtensionItemForWebView:(nonnull WKWebView *)webView completion:(nonnull OnePasswordExtensionItemCompletionBlock)completion;

/*!
 Method used in the UIActivityViewController completion block to fill information into a web view.
 
 @param returnedItems Array which contains the selected activity in the share sheet. Empty array if the share sheet is cancelled by the user.
 @param webView The web view which displays the form to be filled. The active WKWebView. Must not be nil.
 
 @param completion Completion block called on completion with parameters success, and error. The success reply parameter that is YES if the 1Password Extension has been successfully completed or NO otherwise. The error reply parameter that is nil if the 1Password Extension has been successfully completed, or it contains error information about the completion failure.
 */
- (void)fillReturnedItems:(nullable NSArray *)returnedItems intoWebView:(nonnull WKWebView *)webView completion:(nonnull OnePasswordSuccessCompletionBlock)completion;
@end

#if __has_feature(nullability)
NS_ASSUME_NONNULL_END
#endif
