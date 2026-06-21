package tech.hammerhead.point_machine

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "tech.hammerhead.point_machine/open_path"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openFolder" -> result.success(openFolder(call.argument<String>("path")))
                else -> result.notImplemented()
            }
        }
    }

    private fun openFolder(path: String?): Boolean {
        if (!path.isNullOrBlank() && openFileManagerPath(path)) return true
        return openDocumentsTree()
    }

    private fun openFileManagerPath(path: String): Boolean {
        val file = File(path)
        if (!file.exists()) return false

        val storagePath = "/storage/emulated/0/"
        if (path.startsWith(storagePath)) {
            val relative = path.removePrefix(storagePath)
            val docId = "primary:${relative.replace('/', ':')}"
            val uri = DocumentsContract.buildDocumentUri(
                "com.android.externalstorage.documents", docId
            )
            val intent = Intent(Intent.ACTION_VIEW)
                .setData(uri)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (start(intent)) return true
        }

        val intent = Intent(Intent.ACTION_VIEW)
            .setDataAndType(Uri.fromFile(file), "resource/folder")
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (start(intent)) return true

        val fileIntent = Intent(Intent.ACTION_VIEW)
            .setDataAndType(Uri.fromFile(file), "*/*")
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return start(fileIntent)
    }

    private fun openDocumentsTree(): Boolean {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
            .putExtra("android.content.extra.SHOW_ADVANCED", true)
            .addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
            )
        return start(intent)
    }

    private fun start(intent: Intent): Boolean {
        return try {
            startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        } catch (_: SecurityException) {
            false
        } catch (_: IllegalArgumentException) {
            false
        }
    }
}
