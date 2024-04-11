package com.kkg.passwd

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import kotlin.system.measureTimeMillis

class MainActivity: FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "encrypt") {
                val text = call.argument<String>("text")
                val key = call.argument<String>("key")
                if (text != null && key != null) {
                    val encryptedData: String = encrypt(text, key)
                    if (!encryptedData.isEmpty()) {
                        result.success(encryptedData)
                    } else {
                        result.error("UNAVAILABLE", "Не удалось зашифровать", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Отсутствует текст или ключ", null)
                }
            }
            else if (call.method == "decrypt") {
                val data = call.argument<String>("data")
                val key = call.argument<String>("key")
                if (data != null && key != null) {
                    val decryptedData: String = encrypt(data, key)
                    if (!decryptedData.isEmpty()) {
                        result.success(decryptedData)
                    } else {
                        result.error("UNAVAILABLE", "Не удалось зашифровать", null)
                    }
                } else {
                    result.error("UNAVAILABLE", "Не удалось расшифровать", null)
                }
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun encrypt(text: String, key: String): String {
        println("-------------ВХОДНЫЕ ПАРАМЕТРЫ-------------")
        println("Текст: $text")
        println("Мастер ключ: $key")
        val textByte: ByteArray = text.toByteArray();
        print("Текст в байтах: ")
        for (byte in textByte) {
            print(byte)
        }
        val kuznechik: Kuznechik = Kuznechik()
        var encryptByteArray: ByteArray;
        val executionTimeEncrypt = measureTimeMillis {
            encryptByteArray = kuznechik.encrypt(text.toByteArray(), key)
        }
        println("\n\n\n\n-------------ШИФРОВАНИЕ-------------")
        println("Время затраченное на шифрование: $executionTimeEncrypt мс.")
        println("Шифрованный текст: ${String(encryptByteArray)}")
        print("Шифрованный байты: ")
        for (byte in encryptByteArray) {
            print(byte)
        }
        return String(encryptByteArray)
    }

        private fun decrypt(data: String, key: String): String {
        println("-------------ВХОДНЫЕ ПАРАМЕТРЫ-------------")
        println("Текст: $data")
        println("Мастер ключ: $key")
        val textByte: ByteArray = data.toByteArray();
        print("Текст в байтах: ")
        for (byte in textByte) {
            print(byte)
        }
        val kuznechik: Kuznechik = Kuznechik()
        var encryptByteArray: ByteArray;
        val executionTimeEncrypt = measureTimeMillis {
            encryptByteArray = kuznechik.encrypt(textByte, key)
        }
        println("\n\n\n\n-------------ДЕШИФРОВАНИЕ-------------")
        var decryptedByteArray: ByteArray;
        val executionTimeDecrypt = measureTimeMillis {
            decryptedByteArray = kuznechik.decrypt(encryptByteArray, key)
        }
        println("Время затраченное на дешифрование: $executionTimeDecrypt мс.")
        println("Дешифрованный текст: ${String(decryptedByteArray)}")
        print("Дешифрованный байты: ")
        for (b in decryptedByteArray) {
            print(b)
        }
            return String(decryptedByteArray)
    }
}
