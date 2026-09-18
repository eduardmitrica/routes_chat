package com.example.routes_chat

import android.app.NotificationChannel
import android.app.NotificationManager
import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Parts of the screen where a swipe from the edge is the app's, not
        // the system's back gesture, such as the voice message microphone,
        // which the user slides to cancel (SystemGestures in the app).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "routes_chat/system_gestures")
            .setMethodCallHandler { call, result ->
                if (call.method != "exclude") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val rects = (call.arguments as? List<*>).orEmpty().mapNotNull { item ->
                        val edges = (item as? List<*>)?.mapNotNull { (it as? Number)?.toInt() }
                        if (edges?.size == 4) Rect(edges[0], edges[1], edges[2], edges[3]) else null
                    }
                    window.decorView.systemGestureExclusionRects = rects
                }
                result.success(null)
            }
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
