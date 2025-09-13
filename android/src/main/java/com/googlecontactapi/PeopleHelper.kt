package com.googlecontactapi

import android.content.Context
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeTokenRequest
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse
import com.google.api.client.http.HttpTransport
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.gson.GsonFactory
import com.google.api.services.people.v1.PeopleService
import java.io.IOException

object PeopleHelper {
  private const val APPLICATION_NAME = "GoogleContacts Example"

  @Throws(IOException::class)
  fun setUp(
    context: Context?,
    serverAuthCode: String?,
    clientId: String?,
    clientSecret: String?
  ): PeopleService {
    val httpTransport: HttpTransport = NetHttpTransport()
    val redirectUrl = "urn:ietf:wg:oauth:2.0:oob"
    val tokenResponse: GoogleTokenResponse = GoogleAuthorizationCodeTokenRequest(
      httpTransport,
      GsonFactory.getDefaultInstance(),
      clientId,
      clientSecret,
      serverAuthCode,
      redirectUrl
    ).execute()
    // Then, create a GoogleCredential object using the tokens from GoogleTokenResponse
    val credential: GoogleCredential = GoogleCredential.Builder()
      .setClientSecrets(clientId, clientSecret)
      .setTransport(httpTransport)
      .setJsonFactory(GsonFactory.getDefaultInstance())
      .build()
    credential.setFromTokenResponse(tokenResponse)
    // credential can then be used to access Google services
    return PeopleService.Builder(httpTransport, GsonFactory.getDefaultInstance(), credential)
      .setApplicationName(APPLICATION_NAME)
      .build()
  }
}
