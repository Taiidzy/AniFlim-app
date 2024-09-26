package space.aniflim.aniflim

import android.media.MediaCodecList
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "space.aniflim/device_info"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSupportedCodecs") {
                val codecs = getSupportedVideoCodecs()
                result.success(codecs)
            } else {
                result.notImplemented()
            }
        }
    }

    // Получаем поддерживаемые кодеки устройства
    private fun getSupportedVideoCodecs(): List<String> {
        val codecList = MediaCodecList(MediaCodecList.ALL_CODECS)
        val codecInfos = codecList.codecInfos
        val videoCodecs = mutableListOf<String>()

        for (codecInfo in codecInfos) {
            if (!codecInfo.isEncoder) {
                val types = codecInfo.supportedTypes
                for (type in types) {
                    if (type.startsWith("video/")) {
                        videoCodecs.add(type)
                    }
                }
            }
        }

        return videoCodecs
    }
}