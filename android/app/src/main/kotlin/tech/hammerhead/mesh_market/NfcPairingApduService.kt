package tech.hammerhead.mesh_market

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import java.nio.charset.StandardCharsets
import kotlin.math.min

class NfcPairingApduService : HostApduService() {
    companion object {
        const val PREFS = "nfc_pairing"
        const val KEY_PAYLOAD = "payload"

        private val AID = byteArrayOf(
            0xF0.toByte(),
            0x48,
            0x4D,
            0x50,
            0x41,
            0x49,
            0x52
        )
        private val OK = byteArrayOf(0x90.toByte(), 0x00)
        private val NOT_FOUND = byteArrayOf(0x6A.toByte(), 0x82.toByte())
        private val WRONG_PARAMETERS = byteArrayOf(0x6A.toByte(), 0x86.toByte())
        private val INS_NOT_SUPPORTED = byteArrayOf(0x6D, 0x00)
        private val ERROR = byteArrayOf(0x6F, 0x00)
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        val command = commandApdu ?: return ERROR
        if (isSelectAid(command)) return OK

        val payload = payloadBytes() ?: return NOT_FOUND
        if (command.size < 5 || command[0] != 0x80.toByte()) return INS_NOT_SUPPORTED

        return when (command[1].toInt() and 0xff) {
            0x10 -> lengthResponse(payload.size)
            0x20 -> readResponse(command, payload)
            else -> INS_NOT_SUPPORTED
        }
    }

    override fun onDeactivated(reason: Int) {
    }

    private fun payloadBytes(): ByteArray? {
        val payload = getSharedPreferences(PREFS, MODE_PRIVATE)
            .getString(KEY_PAYLOAD, null)
        return payload?.toByteArray(StandardCharsets.UTF_8)
    }

    private fun isSelectAid(command: ByteArray): Boolean {
        if (command.size < 5 || command[0] != 0x00.toByte()) return false
        if (command[1] != 0xA4.toByte() || command[2] != 0x04.toByte()) return false
        val length = command[4].toInt() and 0xff
        if (length != AID.size || command.size < 5 + length) return false
        return AID.indices.all { command[5 + it] == AID[it] }
    }

    private fun lengthResponse(length: Int): ByteArray {
        val data = byteArrayOf(
            ((length ushr 24) and 0xff).toByte(),
            ((length ushr 16) and 0xff).toByte(),
            ((length ushr 8) and 0xff).toByte(),
            (length and 0xff).toByte()
        )
        return data + OK
    }

    private fun readResponse(command: ByteArray, payload: ByteArray): ByteArray {
        val offset = ((command[2].toInt() and 0xff) shl 8) or
            (command[3].toInt() and 0xff)
        if (offset > payload.size) return WRONG_PARAMETERS
        val requested = command[4].toInt() and 0xff
        val size = if (requested == 0) 240 else requested
        val end = min(payload.size, offset + size)
        return payload.copyOfRange(offset, end) + OK
    }
}
