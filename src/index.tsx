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

// Types
export type userDataProps = {
  ClientId: string;
  rediectUrl?: string;
  appId?: string;
  ClientSecret?: string;
};
type GoogleContactResponse = {
  Mobile?: string;
  name: string | null;
  email?: string;
};
export type RegisterResponseProps = {
  status: number;
  message: string;
};
export type ContactResponseDataProps = {
  data: GoogleContactResponse[];
  status: number;
  message?: string;
  nextPageToken: string | null;
};

// Promises
export function RegisterGoogleClientService(userData: userDataProps) {
  return GoogleContactApi.SubmitClientToken(userData);
}
export function FetchGoogleContactService(nextPageToken: string | null = null) {
  return GoogleContactApi.getContact(nextPageToken);
}
export function FetchGoogleOtherContactService(
  nextPageToken: string | null = null
) {
  return GoogleContactApi.getOtherContact(nextPageToken);
}
