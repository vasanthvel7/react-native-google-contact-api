import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-google-contact-api' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const GoogleContactApi = NativeModules.GoogleContactApi
  ? NativeModules.GoogleContactApi
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

// Promises
export function RegisterGoogleClientService(userData) {
  return GoogleContactApi.SubmitClientToken(userData);
}
export function FetchGoogleContactService(nextPageToken = null) {
  return GoogleContactApi.getContact(nextPageToken);
}
export function FetchGoogleOtherContactService(nextPageToken = null) {
  return GoogleContactApi.getOtherContact(nextPageToken);
}
