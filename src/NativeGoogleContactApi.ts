import { TurboModuleRegistry, type TurboModule } from 'react-native';

export type userDataProps = {
  ClientId: string;
  rediectUrl?: string;
  appId?: string;
  ClientSecret?: string;
};

export type SubmitClientTokenResponse = {
  message: string;
  status: number;
};

export type GoogleContactResponse = {
  Mobile?: string;
  name: string | null;
  email?: string;
};

export type ContactResponseDataProps = {
  data: GoogleContactResponse[];
  status: number;
  message?: string;
  nextPageToken: string | null;
};

export type RegisterResponseProps = {
  status: number;
  message: string;
};
export interface Spec extends TurboModule {
  multiply(a: number, b: number): number;
  SubmitClientToken(
    userData: userDataProps
  ): Promise<SubmitClientTokenResponse>;
  getContact(nextPageToken: string | null): Promise<ContactResponseDataProps>;
  getOtherContact(
    nextPageToken: string | null
  ): Promise<ContactResponseDataProps>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('GoogleContactApi');
