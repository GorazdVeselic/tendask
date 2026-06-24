package app.tendask

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val methodChannelName = "app.tendask/reminder_audio"
    private val eventChannelName = "app.tendask/reminder_audio_events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val audio = applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager

        MethodChannel(messenger, methodChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "showNotificationVolumeUi" -> {
                    // ADJUST_RAISE is the consented effect of the in-app "turn on
                    // sound" tap (never a silent override); FLAG_SHOW_UI lets the user
                    // fine-tune on the system slider. STREAM_NOTIFICATION is a
                    // ringer-mode-affected stream, so raising it from 0 also lifts
                    // silent/vibrate back to normal.
                    audio.adjustStreamVolume(
                        AudioManager.STREAM_NOTIFICATION,
                        AudioManager.ADJUST_RAISE,
                        AudioManager.FLAG_SHOW_UI,
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Live audio state: the current reason on listen, then a fresh one on every
        // volume / ringer-mode change so the Flutter banner updates without a poll.
        EventChannel(messenger, eventChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var receiver: BroadcastReceiver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    events.success(reminderAudioReason(audio))
                    val r = object : BroadcastReceiver() {
                        override fun onReceive(context: Context, intent: Intent) {
                            events.success(reminderAudioReason(audio))
                        }
                    }
                    receiver = r
                    val filter = IntentFilter().apply {
                        addAction("android.media.VOLUME_CHANGED_ACTION")
                        addAction(AudioManager.RINGER_MODE_CHANGED_ACTION)
                    }
                    ContextCompat.registerReceiver(
                        applicationContext, r, filter, ContextCompat.RECEIVER_NOT_EXPORTED,
                    )
                }

                override fun onCancel(arguments: Any?) {
                    receiver?.let { applicationContext.unregisterReceiver(it) }
                    receiver = null
                }
            },
        )
    }

    // "audible" when a reminder will make a sound; otherwise why it won't, so the
    // UI can tailor its hint. Vibration and the heads-up are independent of this.
    private fun reminderAudioReason(audio: AudioManager): String = when {
        audio.ringerMode != AudioManager.RINGER_MODE_NORMAL -> "silentMode"
        audio.getStreamVolume(AudioManager.STREAM_NOTIFICATION) == 0 -> "volumeZero"
        else -> "audible"
    }
}
