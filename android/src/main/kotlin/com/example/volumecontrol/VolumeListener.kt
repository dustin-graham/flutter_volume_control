package com.example.volumecontrol

import android.content.Context
import android.database.ContentObserver
import android.media.AudioManager
import android.os.Handler
import io.flutter.plugin.common.EventChannel

class VolumeListener(private val context: Context, private val audioManager: AudioManager, handler: Handler) : ContentObserver(handler), EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        context.contentResolver.registerContentObserver(android.provider.Settings.System.CONTENT_URI, true, this)
        this.eventSink = eventSink
        updateVolume()

    }

    override fun onCancel(p0: Any?) {
        context.contentResolver.unregisterContentObserver(this)
        this.eventSink = null
    }

    override fun onChange(selfChange: Boolean) {
        updateVolume()
    }

    override fun deliverSelfNotifications(): Boolean {
        return false
    }

    private fun updateVolume() {
        val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_RING)
        eventSink?.success(currentVolume)
    }
}