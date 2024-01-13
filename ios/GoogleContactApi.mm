#import "GoogleContactApi.h"
#import <Foundation/Foundation.h>
#import <React/RCTLog.h>
#import <React/RCTConvert.h>

@implementation GoogleContactApi
RCT_EXPORT_MODULE()

- (NSDictionary *)convertJSObjectToObjectiveC:(NSDictionary *)jsObject {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
       // Iterate through properties of the JavaScript object
       for (NSString *key in jsObject) {
           id jsValue = jsObject[key];
           // Use RCTConvert to handle different data types
           if ([jsValue isKindOfClass:[NSString class]]) {
               // Convert string property
               NSString *stringValue = [RCTConvert NSString:jsValue];
               result[key] = stringValue;
           } else if ([jsValue isKindOfClass:[NSNumber class]]) {
               // Convert number property
               NSNumber *numberValue = [RCTConvert NSNumber:jsValue];
               result[key] = numberValue;
           }
       }
       return result;
}

NSString *accessToken;
NSString *clientID = @"";
NSString *redirectUrl = @"";
RCT_EXPORT_METHOD(SubmitClientToken:(NSDictionary *)ClientData
                  resolver:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject

                  )
{
    NSDictionary *ResultData = [self convertJSObjectToObjectiveC:ClientData];
    NSString *ClientId = ResultData[@"ClientId"];
    NSString *RedirectUrl = ResultData[@"rediectUrl"];
    if(ClientId !=NULL && RedirectUrl != NULL)
    {
        clientID = ClientId;
        redirectUrl =RedirectUrl;
        NSNumber *statusCode = @1;
        resolve(@{@"status":statusCode ,@"message":@"Authentication Success"});
    }
    else {
        NSNumber *statusCode = @0;
        resolve(@{@"status":statusCode ,@"message":@"Authentication Failed"});
    }
}

RCT_EXPORT_METHOD(getContact:(NSString *)token
                  resolver:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject

                  )
{
    if (!clientID || [clientID isEqualToString:@""]) {
        NSNumber *statusCode = @0;
        resolve(@{@"status":statusCode ,@"message":@"Authentication Failed"});
        return;
    }
  NSNumber *maxValue = @500;
  NSUInteger uiInteger = [maxValue unsignedIntegerValue];
  NSString *Contacts;
  NSString *ContactsScope = @"https://www.googleapis.com/auth/contacts";

  NSURL *redirUrl =
      [NSURL URLWithString:redirectUrl];

  UIViewController* presentingViewController = RCTPresentedViewController();

  NSURL *authorizationEndpoint =
      [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/v2/auth"];
  NSURL *tokenEndpoint =
      [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v4/token"];

  OIDServiceConfiguration *configuration =
      [[OIDServiceConfiguration alloc]
          initWithAuthorizationEndpoint:authorizationEndpoint
                          tokenEndpoint:tokenEndpoint];

  OIDAuthorizationRequest *request =
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:clientID
                                                      //scopes:@[contactsScope]
                                                      scopes:@[ContactsScope]
                                                 redirectURL:redirUrl
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil];
  if(token != NULL)
  {
    NSString *str = @"https://people.googleapis.com/v1/people/me/connections?pageSize=35&personFields=names,emailAddresses,phoneNumbers&pageToken=";
    Contacts = [str stringByAppendingString:token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:Contacts]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:10.0];
    NSString *str1 = @"Bearer ";

    NSString *Token = [str1 stringByAppendingString:accessToken];
    NSDictionary *headers = @{
      @"Authorization": Token
    };
    [request setAllHTTPHeaderFields:headers];

    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        NSLog(@"%@", error);
      } else {
        NSString* ContactsData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:[ContactsData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSMutableArray *EmailArray =[[NSMutableArray alloc] init];
        NSMutableArray *dataArr=[dict valueForKey:@"connections"];
        NSMutableString *pagedat=[dict valueForKey:@"nextPageToken"];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSMutableString *name = [[NSMutableString alloc] init];

          for (NSDictionary *userData in dataArr) {


            if([userData valueForKey:@"phoneNumbers"] != NULL)
            {
              result =[[userData valueForKey:@"phoneNumbers"] valueForKey:@"value"][0];
               
                
                  if([[userData valueForKey:@"names"] valueForKey:@"displayName"][0] != NULL)
                  {
                      
                    name=[[userData valueForKey:@"names"] valueForKey:@"displayName"][0];

                    [EmailArray  addObject:@{@"Mobile":result,@"name":name}];

                  }
                  else
                  {

                    [EmailArray  addObject:@{@"Mobile":result,@"name": [NSNull null]}];
                  }
            }

          }
          NSNumber *statusCode = @(([EmailArray count] == 0) ? 0 : 1);
          resolve(@{@"data":EmailArray,@"status":statusCode ,@"nextPageToken":([dict valueForKey:@"nextPageToken"] != NULL) ? pagedat : [NSNull null]});
      }
    }];
    [dataTask resume];

  }
  else
  {
      
    Contacts = @"https://people.googleapis.com/v1/people/me/connections?pageSize=35&personFields=names,emailAddresses,phoneNumbers";
  self->_currentAuthorizationFlow =
      [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                     presentingViewController:presentingViewController
          callback:^(OIDAuthState *_Nullable authState,
                     NSError *_Nullable error) {
    if (authState) {

        GTMAppAuthFetcherAuthorization *authorization =
          [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];

      self.authorization = authorization;

      accessToken = authState.lastTokenResponse.accessToken;
      NSString *str1 = @"Bearer ";
      NSString *Token = [str1 stringByAppendingString:authState.lastTokenResponse.accessToken];
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:Contacts]
  cachePolicy:NSURLRequestUseProtocolCachePolicy
  timeoutInterval:10.0];
NSDictionary *headers = @{
  @"Authorization": Token
};

[request setAllHTTPHeaderFields:headers];

[request setHTTPMethod:@"GET"];

NSURLSession *session = [NSURLSession sharedSession];
NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
  if (error) {
    NSLog(@"%@", error);

  } else {
    NSString* ContactsData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:[ContactsData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    NSMutableArray *EmailArray =[[NSMutableArray alloc] initWithCapacity:(uiInteger)];
    NSMutableArray *dataArr=[dict valueForKey:@"connections"];
    NSMutableString *pagedat=[dict valueForKey:@"nextPageToken"];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString *name = [[NSMutableString alloc] init];
    for (NSDictionary *userData in dataArr) {
      if([userData valueForKey:@"phoneNumbers"] != NULL)
      {
        result =[[userData valueForKey:@"phoneNumbers"] valueForKey:@"value"][0];
          if([[userData valueForKey:@"names"] valueForKey:@"displayName"][0] != NULL)
          {
            name=[[userData valueForKey:@"names"] valueForKey:@"displayName"][0];
            [EmailArray  addObject:@{@"Mobile":result,@"name":name}];
          }
          else
          {
            [EmailArray  addObject:@{@"Mobile":result,@"name":[NSNull null]}];
          }
          
      }

    }
    NSNumber *statusCode = @(([EmailArray count] == 0) ? 0 : 1);
    resolve(@{@"data":EmailArray,@"status":statusCode ,@"nextPageToken":([dict valueForKey:@"nextPageToken"] != NULL) ? pagedat : [NSNull null]});
  }
}];
[dataTask resume];
    } else {
      reject(@"Authorization error : ", error.localizedDescription, error);
      self.authorization = nil;
    }
  }];
  }

}
RCT_EXPORT_METHOD(getOtherContact:(NSString *)token
                  resolver:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject

                  )
{
    if (!clientID || [clientID isEqualToString:@""]) {
        NSNumber *statusCode = @0;
        resolve(@{@"status":statusCode ,@"message":@"Authentication Failed"});
        return;
    }
  NSNumber *maxValue = @500;
  NSUInteger uiInteger = [maxValue unsignedIntegerValue];
  NSString *otherContacts;
  NSString *otherContactsScope = @"https://www.googleapis.com/auth/contacts.other.readonly";

  NSURL *redirUrl =
      [NSURL URLWithString:redirectUrl];

  UIViewController* presentingViewController = RCTPresentedViewController();

  NSURL *authorizationEndpoint =
      [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/v2/auth"];
  NSURL *tokenEndpoint =
      [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v4/token"];

  OIDServiceConfiguration *configuration =
      [[OIDServiceConfiguration alloc]
          initWithAuthorizationEndpoint:authorizationEndpoint
                          tokenEndpoint:tokenEndpoint];

  OIDAuthorizationRequest *request =
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:clientID
                                                      //scopes:@[contactsScope]
                                                      scopes:@[otherContactsScope]
                                                 redirectURL:redirUrl
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil];
  if(token != NULL)
  {

    NSString *str = @"https://people.googleapis.com/v1/otherContacts?pageSize=35&readMask=names,emailAddresses&pageToken=";
    otherContacts = [str stringByAppendingString:token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:otherContacts]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:10.0];
    NSString *str1 = @"Bearer ";

    NSString *Token = [str1 stringByAppendingString:accessToken];
    NSDictionary *headers = @{
      @"Authorization": Token
    };
    [request setAllHTTPHeaderFields:headers];

    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        NSLog(@"Error :%@", error);

      } else {
        NSString* otherContactsData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:[otherContactsData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSMutableArray *EmailArray =[[NSMutableArray alloc] init];
        NSMutableArray *dataArr=[dict valueForKey:@"otherContacts"];
        NSMutableString *pagedat=[dict valueForKey:@"nextPageToken"];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSMutableString *name = [[NSMutableString alloc] init];
        for (NSDictionary *userData in dataArr) {
          if([userData valueForKey:@"emailAddresses"] != NULL)
          {
            result =[[userData valueForKey:@"emailAddresses"] valueForKey:@"value"][0];
              if([[userData valueForKey:@"names"]valueForKey:@"displayName"][0] != NULL)
              {
                name=[[userData valueForKey:@"names"] valueForKey:@"displayName"][0];
                [EmailArray  addObject:@{@"email":result,@"name":name}];
              }
              else
              {
                [EmailArray  addObject:@{@"email":result,@"name": [NSNull null]}];
              }
          }

        }
          NSNumber *statusCode = @(([EmailArray count] == 0) ? 0 : 1);
          resolve(@{@"data":EmailArray,@"status":statusCode ,@"nextPageToken":([dict valueForKey:@"nextPageToken"] != NULL) ? pagedat : [NSNull null]});
      }
    }];
    [dataTask resume];

  }
  else
  {
    otherContacts = @"https://people.googleapis.com/v1/otherContacts?pageSize=35&readMask=names,emailAddresses";
  self->_currentAuthorizationFlow =
      [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                     presentingViewController:presentingViewController
          callback:^(OIDAuthState *_Nullable authState,
                     NSError *_Nullable error) {
    if (authState) {

      GTMAppAuthFetcherAuthorization *authorization =
          [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];

      self.authorization = authorization;

      accessToken = authState.lastTokenResponse.accessToken;
      NSString *str1 = @"Bearer ";

      NSString *Token = [str1 stringByAppendingString:authState.lastTokenResponse.accessToken];
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:otherContacts]
  cachePolicy:NSURLRequestUseProtocolCachePolicy
  timeoutInterval:10.0];
NSDictionary *headers = @{
  @"Authorization": Token
};
[request setAllHTTPHeaderFields:headers];

[request setHTTPMethod:@"GET"];

NSURLSession *session = [NSURLSession sharedSession];
NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
  if (error) {
    NSLog(@"%@", error);
  } else {
    NSString* otherContactsData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:[otherContactsData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    NSMutableArray *EmailArray =[[NSMutableArray alloc] initWithCapacity:(uiInteger)];
    NSMutableArray *dataArr=[dict valueForKey:@"otherContacts"];
    NSMutableString *pagedat=[dict valueForKey:@"nextPageToken"];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString *name = [[NSMutableString alloc] init];
      
    for (NSDictionary *userData in dataArr) {
      if([userData valueForKey:@"emailAddresses"] != NULL)
      {
        result =[[userData valueForKey:@"emailAddresses"] valueForKey:@"value"][0];
            if([[userData valueForKey:@"names"]valueForKey:@"displayName"][0] != NULL)
            {
              name=[[userData valueForKey:@"names"] valueForKey:@"displayName"][0];
              [EmailArray  addObject:@{@"email":result,@"name":name}];
            }
            else
            {
              [EmailArray  addObject:@{@"email":result,@"name": [NSNull null]}];
            }
      }

    }
      NSNumber *statusCode = @(([EmailArray count] == 0) ? 0 : 1);
      resolve(@{@"data":EmailArray,@"status":statusCode ,@"nextPageToken":([dict valueForKey:@"nextPageToken"] != NULL) ? pagedat : [NSNull null]});
  }
}];
[dataTask resume];

    } else {
      reject(@"Authorization error : ", error.localizedDescription, error);
      self.authorization = nil;
    }
  }];
  }

}

@end
