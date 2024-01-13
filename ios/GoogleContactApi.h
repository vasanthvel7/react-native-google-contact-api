#import <AppAuth/AppAuth.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>
#import <GTMAppAuth/GTMAppAuth.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNGoogleContactApiSpec.h"

@interface GoogleContactApi : NSObject <NativeGoogleContactApiSpec>
@property(nonatomic, nullable)
    id<OIDExternalUserAgentSession> currentAuthorizationFlow;
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

@interface SubmitClientProps : NSDictionary
@property (nonatomic, strong) NSString * _Nullable ClientId;
@property (nonatomic, strong) NSString * _Nullable appId;
@property (nonatomic, strong) NSString * _Nullable ClientSecret;
#else
#import <React/RCTBridgeModule.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>




@interface GoogleContactApi : NSObject <RCTBridgeModule>
#endif
@property(nonatomic, nullable)
    id<OIDExternalUserAgentSession> currentAuthorizationFlow;
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

@end


@interface SubmitClientProps : NSDictionary

@property (nonatomic, strong) NSString * _Nullable ClientId;
@property (nonatomic, strong) NSString * _Nullable appId;
@property (nonatomic, strong) NSString * _Nullable ClientSecret;

@end


