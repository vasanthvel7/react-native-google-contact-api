declare module 'react-native-google-contact-api' {
  export type userDataProps = {
    ClientId: string;
    rediectUrl?: string;
    appId?: string;
    ClientSecret?: string;
  };
  export type GoogleContactResponse = {
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
  export function RegisterGoogleClientService(
    userData: userDataProps
  ): Promise<RegisterResponseProps>;

  export function FetchGoogleContactService(
    nextPageToken?: string | null
  ): Promise<ContactResponseDataProps>;

  export function FetchGoogleOtherContactService(
    nextPageToken?: string | null
  ): Promise<ContactResponseDataProps>;
}
