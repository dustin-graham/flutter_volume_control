package com.example.volumecontrol

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class VolumeControlPlugin(val audioManager: AudioManager, val notificationManager: NotificationManager, val activityStarter: ((intent: Intent) -> Unit)) : MethodCallHandler {

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val context = registrar.context()
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channel = MethodChannel(registrar.messenger(), "volume_control")
            val volumeEventChannel = EventChannel(registrar.messenger(), "volume_change_events")
            val volumeListener = VolumeListener(context, audioManager, Handler())
            volumeEventChannel.setStreamHandler(volumeListener)
            channel.setMethodCallHandler(VolumeControlPlugin(audioManager, notificationManager) { intent -> context.startActivity(intent) })
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "setVolume") {
            val volumeLevel = call.argument<Int>("level") // percent
            audioManager.setStreamVolume(AudioManager.STREAM_RING, volumeLevel!!, AudioManager.FLAG_VIBRATE)
            Log.d("VOLUME_CONTROL", "setting volume level: $volumeLevel")
            result.success(volumeLevel)
        } else if (call.method == "volumeRange") {
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_RING)
            result.success(listOf(0,maxVolume))
        } else if (call.method == "hasAccess") {
            result.success(hasAccess())
        } else if (call.method == "getAccess") {
            getAccess()
            result.success(true)
        } else {
            result.notImplemented()
        }
    }

    private fun hasAccess(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !notificationManager.isNotificationPolicyAccessGranted) {
            return false
        }
        return true
    }

    private fun getAccess() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !notificationManager.isNotificationPolicyAccessGranted) {

            val intent = Intent(
                    android.provider.Settings
                            .ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)

            activityStarter(intent)
        }
    }
}
