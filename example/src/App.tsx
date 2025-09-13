import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  Platform,
} from 'react-native';
import {
  FetchGoogleContactService,
  FetchGoogleOtherContactService,
  RegisterGoogleClientService,
} from 'react-native-google-contact-api';

export const GOOGLE_SIGNIN_IOS_CLIENT_ID = 'GOOGLE_SIGNIN_IOS_CLIENT_ID';
export const GOOGLE_CONTACTS_REDIRECT_URL_IOS =
  'GOOGLE_CONTACTS_REDIRECT_URL_IOS';
export const FIREBASE_APP_ID = 'FIREBASE_APP_ID';
export const GOOGLE_CONTACTS_SERVER_CLIENT_ID =
  'GOOGLE_CONTACTS_SERVER_CLIENT_ID';
export const GOOGLE_CONTACTS_SERVER_CLIENT_SECRET =
  'GOOGLE_CONTACTS_SERVER_CLIENT_SECRET';

export default function App() {
  return (
    <View style={styles.container}>
      <View style={styles.container}>
        <TouchableOpacity
          style={styles.buttons}
          onPress={() => {
            let userData = {
              ClientId:
                Platform.OS === 'ios'
                  ? GOOGLE_SIGNIN_IOS_CLIENT_ID
                  : GOOGLE_CONTACTS_SERVER_CLIENT_ID, // Android or IOS Client id Required
              rediectUrl: GOOGLE_CONTACTS_REDIRECT_URL_IOS, // Required for IOS
              appId: FIREBASE_APP_ID, // Required for Android
              ClientSecret: GOOGLE_CONTACTS_SERVER_CLIENT_SECRET, // Required for Android
            };
            RegisterGoogleClientService(userData)
              .then((res) => {
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
              .then((res) => {
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
              .then((res) => {
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
