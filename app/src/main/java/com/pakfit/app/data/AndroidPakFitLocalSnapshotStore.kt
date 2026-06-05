package com.pakfit.app.data

import android.content.Context
import com.pakfit.app.domain.PakFitSnapshotCodec
import com.pakfit.app.domain.PakFitUserSnapshot

class AndroidPakFitLocalSnapshotStore(
    context: Context,
    private val codec: PakFitSnapshotCodec = PakFitSnapshotCodec()
) {
    private val preferences = context.applicationContext.getSharedPreferences(
        "pakfit_local_snapshot",
        Context.MODE_PRIVATE
    )

    fun save(snapshot: PakFitUserSnapshot) {
        preferences.edit()
            .putString(SNAPSHOT_KEY, codec.encode(snapshot))
            .apply()
    }

    fun restoreOrNull(): PakFitUserSnapshot? {
        return preferences.getString(SNAPSHOT_KEY, null)?.let { payload ->
            runCatching { codec.decode(payload) }.getOrNull()
        }
    }

    fun export(snapshot: PakFitUserSnapshot): String = codec.encode(snapshot)

    fun clear() {
        preferences.edit().remove(SNAPSHOT_KEY).apply()
    }

    companion object {
        private const val SNAPSHOT_KEY = "snapshot_payload"
    }
}
