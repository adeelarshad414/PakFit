package com.pakfit.app.data

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import com.pakfit.app.domain.PakFitSnapshotCodec
import com.pakfit.app.domain.PakFitUserSnapshot
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import android.util.Base64

class AndroidPakFitLocalSnapshotStore(
    context: Context,
    private val codec: PakFitSnapshotCodec = PakFitSnapshotCodec()
) {
    private val preferences = context.applicationContext.getSharedPreferences(
        "pakfit_local_snapshot",
        Context.MODE_PRIVATE
    )

    fun save(snapshot: PakFitUserSnapshot) {
        val payload = codec.encode(snapshot)
        preferences.edit()
            .putString(SNAPSHOT_KEY, encrypt(payload))
            .apply()
    }

    fun restoreOrNull(): PakFitUserSnapshot? {
        return preferences.getString(SNAPSHOT_KEY, null)?.let { payload ->
            runCatching {
                val encrypted = payload.startsWith(ENCRYPTED_PREFIX)
                val decodedPayload = if (encrypted) {
                    decrypt(payload)
                } else {
                    payload
                }
                codec.decode(decodedPayload).also { snapshot ->
                    if (!encrypted) save(snapshot)
                }
            }.getOrNull()
        }
    }

    fun export(snapshot: PakFitUserSnapshot): String = codec.encode(snapshot)

    fun clear() {
        preferences.edit().remove(SNAPSHOT_KEY).apply()
    }

    private fun encrypt(plaintext: String): String {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateKey())
        val encryptedBytes = cipher.doFinal(plaintext.toByteArray(Charsets.UTF_8))
        return listOf(
            ENCRYPTED_PREFIX,
            Base64.encodeToString(cipher.iv, Base64.NO_WRAP),
            Base64.encodeToString(encryptedBytes, Base64.NO_WRAP)
        ).joinToString(":")
    }

    private fun decrypt(payload: String): String {
        val parts = payload.split(":")
        require(parts.size == 3 && parts[0] == ENCRYPTED_PREFIX) { "Unsupported encrypted snapshot payload." }
        val iv = Base64.decode(parts[1], Base64.NO_WRAP)
        val encryptedBytes = Base64.decode(parts[2], Base64.NO_WRAP)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, getOrCreateKey(), GCMParameterSpec(GCM_TAG_BITS, iv))
        return String(cipher.doFinal(encryptedBytes), Charsets.UTF_8)
    }

    private fun getOrCreateKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).also { it.load(null) }
        (keyStore.getEntry(KEY_ALIAS, null) as? KeyStore.SecretKeyEntry)?.let { return it.secretKey }

        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        keyGenerator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setRandomizedEncryptionRequired(true)
                .build()
        )
        return keyGenerator.generateKey()
    }

    companion object {
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private const val ENCRYPTED_PREFIX = "pakfit-enc-v1"
        private const val GCM_TAG_BITS = 128
        private const val KEY_ALIAS = "pakfit_local_snapshot_key_v1"
        private const val SNAPSHOT_KEY = "snapshot_payload"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
    }
}
