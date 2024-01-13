# react-native-google-contact-api

A React Native package that facilitates the retrieval of Google Contacts and Other Contacts from Google. This package utilizes the `react-native-google-contact-api` library, providing a simple and efficient way to integrate Google Contacts functionality into your React Native applications.


## Installation

```sh
npm install react-native-google-contact-api
```

# Android Configuration Guide

## Firebase Configuration

Obatain SHA1 Key from the KeyStore file, add it to the [Firebase Console](https://console.firebase.google.com/) by following these steps:

1. Sign in to Firebase and open your project.
2. Click the Settings icon and select Project settings.
3. In the Your apps card, select the package name of the app you need to add SHA1 to.
4. Click "Add fingerprint."

Then, go to [Firebase Console](https://console.firebase.google.com/), select your app, and add the SHA1 value under Project Settings (gear icon in the upper left) -> Your Apps - SHA certificate fingerprints.

You can get your `webClientId` from [Google Developer Console](https://console.developers.google.com/apis/credentials).

### Steps To Generate OAUTH2 `webClientId`
1. Create credentials using OAUTH Client ID Configuration.
2. Select Application Type as Web Application.
3. Add your Application name and Redirect URI.
4. The WebClient Id is generated for your application.

## Gradle Configuration

If you're running your app in debug mode and not using `webClientId` or you're sure it's correct, the problem might be a signature (SHA-1 or SHA-256) mismatch. Add the following to `android/app/build.gradle`:

```gradle
signingConfigs {
    debug {
        // Add your signing configuration details here
    }
    release {
       // Add your signing configuration details here
    }
}
```
And Then
```gradle
 android {
    packagingOptions {
        exclude 'META-INF/DEPENDENCIES'
    }
    .....
}
```

# IOS Configuration Guide

## Firebase Configuration

You can get your `webClientId` from [Google Developer Console](https://console.developers.google.com/apis/credentials).

1. Create Credentials By using OAUTH Client ID Configuration
2. Select Application Type As IOS
3. Add Your IOS Application name and Bundle Id
4. WebClient Id is Generated for Your Application


## Usage

Before you can fetch contacts, you need to register your credentials. This process involves obtaining the necessary API keys, tokens, or any other authentication information required by the service or library you are using for contact retrieval.

To register your credentials and integrate them into your React Native application, follow the example code below. This example demonstrates the process of registering API keys for Google Contacts using the [react-native-google-contact-api](https://www.npmjs.com/package/react-native-google-contact-api) library.

## RegisterGoogleClientService
```js
import {
  FetchGoogleContactService,
  FetchGoogleOtherContactService,
  RegisterGoogleClientService,
  ContactResponseDataProps,
  RegisterResponseProps,
  userDataProps,
} from 'react-native-google-contact-api';

 ....


 let userData: userDataProps = {
    ClientId: 'ClientId', // Android or IOS Client id Required
    rediectUrl: 'rediectUrl', // Required for IOS
    appId: 'appId', // Required for Android
    ClientSecret: 'ClientSecret', // Required for Android
};
RegisterGoogleClientService(userData)
.then((res: RegisterResponseProps) => {
     // Response Data
})
.catch((e: any) => {
    // Error Response
});
```

There are two types of Contact Fetching Methods available in this Package.

1. FetchGoogleContactService
2. FetchGoogleOtherContactService

## Fetch GoogleContact Service
When dealing with paginated data, services often provide a `next_page_token` as part of the API response to help fetch subsequent pages of data.
```js
FetchGoogleContactService(next_page_token)  // ===> next_page_token is Optional
.then((res: ContactResponseDataProps) => {
    // Response Data
})
.catch((e: any) => {
  // Error Response
});
```


## Fetch GoogleOtherContact Service
When dealing with paginated data, services often provide a `next_page_token` as part of the API response to help fetch subsequent pages of data.
```js
FetchGoogleOtherContactService(next_page_token)  // ===> next_page_token is Optional
.then((res: ContactResponseDataProps) => {
    // Response Data
})
.catch((e: any) => {
  // Error Response
});
```
## Response JSON Object

`RegisterGoogleClientService()` Method Reponse

| Key               | Value                            | Description                                                                                                |
| ----------------- | -------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| status            |  1 or 0                     |  `1` - Success, `0` - Failed                                            
| message           | Message about Success or Failure |

`FetchGoogleContactService()` and `FetchGoogleOtherContactService()` Methods Reponse

| Key              | Value                                     | Description                                                                                                                                                                                                                                           |
| ---------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| status            |  1 or 0                     |  `1` - Success, `0` - Failed                                                                                                             |
| nextPageToken      | String                                | Next page token response from Google.it will return null when next page is empty                                                                                                                                |
| data       | User Array List                                | response user data from Google  |
 message          |          |Message will receive only Failure 


## License

MIT
