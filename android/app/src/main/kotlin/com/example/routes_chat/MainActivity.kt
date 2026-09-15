package com.example.routes_chat

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    // Each kind of notification has a channel of its own, which the user can
    // mute in the phone's settings. The ids must match CHANNELS in
    // functions/notify.js; a test checks it.
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                "messages",
                "Messages",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply { description = "New messages in your chats" },
        )
        manager.createNotificationChannel(
            NotificationChannel(
                "friend_requests",
                "Friend requests",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply { description = "People who want to add you as a friend" },
        )
    }
}
