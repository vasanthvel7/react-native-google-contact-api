package com.googlecontactapi

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.AsyncTask
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.BaseActivityEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil.runOnUiThread
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.module.annotations.ReactModule
import com.google.android.gms.auth.api.Auth
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.auth.api.signin.GoogleSignInResult
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.Scope
import com.google.android.gms.tasks.Task
import com.google.api.services.people.v1.PeopleService
import com.google.api.services.people.v1.model.EmailAddress
import com.google.api.services.people.v1.model.ListConnectionsResponse
import com.google.api.services.people.v1.model.ListOtherContactsResponse
import com.google.api.services.people.v1.model.Name
import com.google.api.services.people.v1.model.Person
import com.google.api.services.people.v1.model.PhoneNumber
import com.google.gdata.util.*
import java.io.IOException

@ReactModule(name = GoogleContactApiModule.NAME)
class GoogleContactApiModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private var mGoogleSignInClient: GoogleSignInClient? = null
  var context: Context
//  var currentActivity: Activity? = null
  var signInIntent: Intent? = null
  var ClientId: String? = null
  var Clientsecret: String? = null
  var AppId: String? = null
  var Type: String? = null
  var contactnextPageToken: String? = null
  var nextPageToken: String? = null
  var EmailListReturn: Promise? = null
  var res: ListOtherContactsResponse? = null
  var peopleService: PeopleService? = null
  var acct: GoogleSignInAccount? = null

  init {
    reactContext.addActivityEventListener(ActivityEventListener())
    context = reactContext
  }

  private inner class ActivityEventListener : BaseActivityEventListener() {
    override fun onActivityResult(
      activity: Activity,
      requestCode: Int,
      resultCode: Int,
      intent: Intent?
    ) {
      if (requestCode == RC_GET_AUTH_CODE) {
        val task: Task<GoogleSignInAccount> = GoogleSignIn.getSignedInAccountFromIntent(intent)
        val result: GoogleSignInResult? = intent?.let {
          Auth.GoogleSignInApi.getSignInResultFromIntent(
            it
          )
        }
        try {
          val account: GoogleSignInAccount = task.getResult(ApiException::class.java)
          val acc: GoogleSignInAccount? = result?.getSignInAccount()
          if (account == null) {
            EmailListReturn!!.reject("msg", "Account is Null")
          } else {
            acct = GoogleSignIn.getLastSignedInAccount(activity)
            val serverAuthCode: String? = acc?.getServerAuthCode()
            PeoplesAsync().execute(serverAuthCode)
          }
        } catch (e: ApiException) {
          EmailListReturn?.reject("msg", java.lang.String.valueOf(e.getStatus()))
        }
      }
    }
  }

  internal inner class PeoplesAsync : AsyncTask<String?, Void?, List<String>>() {

    override fun onPreExecute() {
      super.onPreExecute()
      // Optional: Show a loading spinner
    }

    override fun doInBackground(vararg params: String?): List<String> {
      val nameList: MutableList<String> = ArrayList()
      try {
        val token = params[0]
        if (token != null) {
          peopleService = PeopleHelper.setUp(context, token, ClientId, Clientsecret)
          if (Type == "OtherContacts") {
            fetchOtherContacts(null)
          } else {
            fetchContacts(null)
          }
        } else {
          EmailListReturn?.reject("msg", "Token is null")
        }
      } catch (e: IOException) {
        EmailListReturn?.reject("msg", e.toString())
        e.printStackTrace()
      }
      return nameList
    }

    override fun onPostExecute(result: List<String>?) {
      super.onPostExecute(result)
      // Optional: handle the result, e.g., update UI
    }
  }


  fun fetchContacts(token: String?) {
    try {
      val contactsList = Arguments.createMap()
      val contactsarray: WritableArray = WritableNativeArray()
      val response: ListConnectionsResponse = if (token == null) {
        peopleService!!.people().connections()
          .list("people/me")
          .setPersonFields(
            "addresses,ageRanges,birthdays,coverPhotos,emailAddresses,genders,metadata,names,nicknames,occupations,organizations,phoneNumbers,photos,urls"
          )
          .setPageSize(45)
          .execute()
      } else {
        peopleService!!.people().connections()
          .list("people/me")
          .setPersonFields(
            "addresses,ageRanges,birthdays,coverPhotos,emailAddresses,genders,metadata,names,nicknames,occupations,organizations,phoneNumbers,photos,urls"
          )
          .setPageToken(token)
          .setPageSize(45)
          .execute()
      }
      contactnextPageToken = response.getNextPageToken()
      if (contactnextPageToken != null) {
        contactsList.putString("nextPageToken", response.getNextPageToken())
      } else {
        contactsList.putString("nextPageToken", null)
      }
      val Contacts: List<Person> = response.getConnections()
      if (Contacts != null) {
        for (person in Contacts) {
          val phoneNumbers: List<PhoneNumber> = person.getPhoneNumbers()

          val names: List<Name> = person.getNames()
          val emailAddresses: List<EmailAddress> = person.getEmailAddresses()
          if (!person.isEmpty()) {
            if (phoneNumbers != null) for (phonenumbers in phoneNumbers) {
              val contactmap = Arguments.createMap()
              if (names != null) {
                contactmap.putString("name", names[0].getDisplayName())
                contactmap.putString("phoneNumber", phonenumbers.getValue())
                if (emailAddresses != null) {
                  contactmap.putString("emailAddress ", emailAddresses[0].getValue())
                }

                contactsarray.pushMap(contactmap)
              } else {
                contactmap.putNull("name")
                contactmap.putString("phone Number", phonenumbers.getValue())
                if (emailAddresses != null) {
                  contactmap.putString("emailAddress ", emailAddresses[0].getValue())
                }
                contactsarray.pushMap(contactmap)
              }
            }
          }
        }
      }
      contactsList.putArray("data", contactsarray)
      if (Contacts != null) {
        contactsList.putInt("status", 1)
      } else {
        contactsList.putInt("status", 0)
      }
      EmailListReturn!!.resolve(contactsList)
    } catch (e: Exception) {
      EmailListReturn!!.reject("msg", e.toString())
      e.printStackTrace()
    }
  }

  fun fetchOtherContacts(token: String?) {
    try {
      val contactList = Arguments.createMap()
      val array: WritableArray = WritableNativeArray()
      res = if (token == null) {
        peopleService!!.otherContacts().list()
          .setReadMask("emailAddresses,names")
          .execute()
      } else {
        peopleService!!.otherContacts().list()
          .setReadMask("emailAddresses,names")
          .setPageToken(token)
          .execute()
      }
      nextPageToken = res!!.getNextPageToken()
      contactList.putString("nextPageToken", nextPageToken)
      val otherContacts: List<Person> = res!!.getOtherContacts()
      if (otherContacts != null) {
        for (person in otherContacts) {
          val emailAddresses: List<EmailAddress> = person.getEmailAddresses()
          val names: List<Name> = person.getNames()
          if (!person.isEmpty()) {
            if (emailAddresses != null) for (emailAddress in emailAddresses) {
              val map = Arguments.createMap()
              if (names != null) {
                for (name in names) {
                  map.putString("name", name.getDisplayName())
                  map.putString("email", emailAddress.getValue())
                  array.pushMap(map)
                }
              } else {
                map.putNull("name")
                map.putString("email", emailAddress.getValue())
                array.pushMap(map)
              }
            }
          }
        }
      }
      if (otherContacts != null) {
        contactList.putInt("status", 1)
      } else {
        contactList.putInt("status", 0)
      }
      contactList.putArray("data", array)

      EmailListReturn!!.resolve(contactList)
      return
    } catch (e: Exception) {
      EmailListReturn!!.reject("msg", e.toString())
      e.printStackTrace()
    }
  }


  @ReactMethod
  @Throws(IOException::class, ServiceException::class)
  fun SubmitClientToken(userData: ReadableMap, promise: Promise) {
    ClientId = userData.getString("ClientId")
    AppId = userData.getString("appId")
    Clientsecret = userData.getString("ClientSecret")
    if (ClientId != null && AppId != null && Clientsecret != null) {
      val tokenMap = Arguments.createMap()
      tokenMap.putString("message", "Authentication Success")
      tokenMap.putInt("status", 1)
      promise.resolve(tokenMap)
    } else {
      val tokenMap = Arguments.createMap()
      tokenMap.putString("message", "Authentication Failed")
      tokenMap.putInt("status", 0)
      promise.resolve(tokenMap)
    }
  }

  @ReactMethod
  @Throws(IOException::class, ServiceException::class)
  fun getContact(nextToken: String?, promise: Promise) {
    if (ClientId != null && AppId != null && Clientsecret != null) {
      if (nextToken == null) {
        if (mGoogleSignInClient != null) {
          mGoogleSignInClient!!.signOut()
        }
        EmailListReturn = promise

        val gso: GoogleSignInOptions = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
          .requestServerAuthCode(ClientId!!)
          .requestScopes(
            Scope("https://www.googleapis.com/auth/contacts"),
            Scope("https://www.googleapis.com/auth/contacts.other.readonly")
          )
          .requestProfile()
          .requestEmail()
          .build()
        mGoogleSignInClient = GoogleSignIn.getClient(context, gso)
        authCode
        Type = "Contacts"
      } else {
        EmailListReturn = promise
        fetchContacts(nextToken)
        Type = "Contacts"
      }
    } else {
      val tokenMap = Arguments.createMap()
      tokenMap.putString("message", "Authentication Failed")
      tokenMap.putInt("status", 0)
      promise.resolve(tokenMap)
    }
  }

  @ReactMethod
  @Throws(IOException::class, ServiceException::class)
  fun getOtherContact(nextToken: String?, promise: Promise) {
    if (ClientId != null && AppId != null && Clientsecret != null) {
      if (nextToken == null) {
        if (mGoogleSignInClient != null) {
          mGoogleSignInClient!!.signOut()
        }
        EmailListReturn = promise
        val gso: GoogleSignInOptions = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
          .requestServerAuthCode(ClientId!!)
          .requestScopes(
            Scope("https://www.googleapis.com/auth/contacts"),
            Scope("https://www.googleapis.com/auth/contacts.other.readonly")
          )
          .requestProfile()
          .requestEmail()
          .build()
        mGoogleSignInClient = GoogleSignIn.getClient(context, gso)
        authCode
        Type = "OtherContacts"
      } else {
        EmailListReturn = promise
        fetchOtherContacts(nextToken)
        Type = "OtherContacts"
      }
    } else {
      val tokenMap = Arguments.createMap()
      tokenMap.putString("message", "Authentication Failed")
      tokenMap.putInt("status", 0)
      promise.resolve(tokenMap)
    }
  }

  private val authCode: Unit
    get() {
      signInIntent = mGoogleSignInClient!!.getSignInIntent()
      signInIntent!!.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      var currentActivity = reactApplicationContext.currentActivity
      runOnUiThread {
        val signInIntent: Intent = mGoogleSignInClient!!.getSignInIntent()
        currentActivity!!.startActivityForResult(
          signInIntent,
          RC_GET_AUTH_CODE
        )
      }
    }

  override fun getName(): String {
    return NAME
  }


  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun multiply(a: Double, b: Double, promise: Promise) {
    promise.resolve(a * b)
  }

  companion object {
    const val NAME: String = "GoogleContactApi"
    private const val RC_GET_AUTH_CODE = 6080
  }
}
