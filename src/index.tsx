import GoogleContactApi, { type userDataProps } from './NativeGoogleContactApi';

export function multiply(a: number, b: number): number {
  return GoogleContactApi.multiply(a, b);
}

export function RegisterGoogleClientService(userData: userDataProps) {
  return GoogleContactApi.SubmitClientToken(userData);
}
export function FetchGoogleContactService(nextPageToken = null) {
  return GoogleContactApi.getContact(nextPageToken);
}
export function FetchGoogleOtherContactService(nextPageToken = null) {
  return GoogleContactApi.getOtherContact(nextPageToken);
}
