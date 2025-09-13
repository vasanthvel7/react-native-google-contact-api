#import <GoogleContactApiSpec/GoogleContactApiSpec.h>
#import <AppAuth/AppAuth.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>
#import <GTMAppAuth/GTMAppAuth.h>

@interface GoogleContactApi : NSObject <NativeGoogleContactApiSpec>
@property(nonatomic, nullable)
    id<OIDExternalUserAgentSession> currentAuthorizationFlow;
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

@property (nonatomic, strong) NSString * _Nullable ClientId;
@property (nonatomic, strong) NSString * _Nullable appId;
@property (nonatomic, strong) NSString * _Nullable ClientSecret;
@end

