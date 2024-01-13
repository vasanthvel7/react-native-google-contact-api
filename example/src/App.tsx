import * as React from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import {
  FetchGoogleContactService,
  FetchGoogleOtherContactService,
  RegisterGoogleClientService,
  type ContactResponseDataProps,
  type RegisterResponseProps,
  type userDataProps,
} from 'react-native-google-contact-api';

export default function App() {
  return (
    <View style={styles.container}>
      <View style={styles.container}>
        <TouchableOpacity
          style={styles.buttons}
          onPress={() => {
            let userData: userDataProps = {
              ClientId: 'ClientId', // Android or IOS Client id Required
              rediectUrl: 'rediectUrl', // Required for IOS
              appId: 'appId', // Required for Android
              ClientSecret: 'ClientSecret', // Required for Android
            };
            RegisterGoogleClientService(userData)
              .then((res: RegisterResponseProps) => {
                console.log(res, 'Response');
              })
              .catch((e: any) => {
                console.log(e, 'Error');
              });
          }}
        >
          <Text style={{ color: '#FFFFFF' }}>Submit Credentials</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.buttons}
          onPress={() => {
            FetchGoogleContactService()
              .then((res: ContactResponseDataProps) => {
                console.log(res, 'Response');
              })
              .catch((e: any) => {
                console.log(e, 'Error');
              });
          }}
        >
          <Text style={{ color: '#FFFFFF' }}>Get Contacts</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.buttons}
          onPress={() => {
            FetchGoogleOtherContactService()
              .then((res: ContactResponseDataProps) => {
                console.log(res, 'Response');
              })
              .catch((e: any) => {
                console.log(e, 'Error');
              });
          }}
        >
          <Text style={{ color: '#FFFFFF' }}>Get OtherContacts</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttons: {
    width: '100%',
    padding: 10,
    borderRadius: 10,
    backgroundColor: 'green',

    marginVertical: 10,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
