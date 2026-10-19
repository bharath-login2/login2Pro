package com.login2Pro

import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.login2Pro/sim_info"
    private val RECORDING_CHANNEL = "com.login2Pro/call_recording"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // SIM channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getActiveSims") {
                try {
                    val simList = getActiveSimList()
                    result.success(simList)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", e.localizedMessage, null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Call recording channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RECORDING_CHANNEL
        ).setMethodCallHandler { call, result ->
            Log.d("CALL_RECORDING", "MethodChannel received method call: ${call.method}")
            when (call.method) {
                "getRecentRecordings" -> {
                    Thread {
                        try {
                            val recordings = getNewRecordings()
                            runOnUiThread { result.success(recordings) }
                        } catch (e: Exception) {
                            Log.e("CALL_RECORDING", "Error in getRecentRecordings", e)
                            runOnUiThread { result.error("RECORDING_ERROR", e.localizedMessage, null) }
                        }
                    }.start()
                }

                "getPhoneRecordings" -> {
                    Thread {
                        try {
                            val recordings = getNewRecordings()
                            runOnUiThread { result.success(recordings) }
                        } catch (e: Exception) {
                            Log.e("CALL_RECORDING", "Error in getPhoneRecordings", e)
                            runOnUiThread { result.error("PHONE_RECORDING_ERROR", e.localizedMessage, null) }
                        }
                    }.start()
                }

                "getNewPhoneRecordings" -> {
                    Thread {
                        try {
                            val recordings = getNewRecordings()
                            runOnUiThread { result.success(recordings) }
                        } catch (e: Exception) {
                            Log.e("CALL_RECORDING", "Error in getNewPhoneRecordings", e)
                            runOnUiThread { result.error("NEW_PHONE_RECORDING_ERROR", e.localizedMessage, null) }
                        }
                    }.start()
                }

                "getMediaStoreRecordings" -> {
                    Thread {
                        try {
                            val recordings = getNewRecordings()
                            runOnUiThread { result.success(recordings) }
                        } catch (e: Exception) {
                            Log.e("CALL_RECORDING", "Error in getMediaStoreRecordings", e)
                            runOnUiThread { result.error("MEDIASTORE_RECORDING_ERROR", e.localizedMessage, null) }
                        }
                    }.start()
                }

                "getNewRecordings" -> {
                    Thread {
                        try {
                            val recordings = getNewRecordings()
                            runOnUiThread { result.success(recordings) }
                        } catch (e: Exception) {
                            Log.e("CALL_RECORDING", "Error in getNewRecordings", e)
                            runOnUiThread { result.error("NEW_RECORDING_ERROR", e.localizedMessage, null) }
                        }
                    }.start()
                }

                "requestAudioPermission" -> {
                    try {
                        requestAudioPermission()
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("CALL_RECORDING", "Error requesting audio permission", e)
                        result.error("PERMISSION_ERROR", e.localizedMessage, null)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // EXISTING SIM CODE
    private fun getActiveSimList(): List<Map<String, Any?>> {
        val list = mutableListOf<Map<String, Any?>>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
            val activeSubscriptionInfoList: List<SubscriptionInfo>? = try {
                subscriptionManager?.activeSubscriptionInfoList
            } catch (e: SecurityException) {
                Log.e("NATIVE_SIM", "SecurityException reading activeSubscriptionInfoList", e)
                null
            }

            Log.d("NATIVE_SIM", "Active Subscription List Count: ${activeSubscriptionInfoList?.size ?: 0}")

            activeSubscriptionInfoList?.forEach { info ->
                val subId = info.subscriptionId
                val slotIdx = info.simSlotIndex
                val dispName = info.displayName?.toString() ?: ""
                val carrier = info.carrierName?.toString() ?: ""
                val num = try { info.number?.toString() ?: "" } catch (e: Exception) { "" }

                val simMap = HashMap<String, Any?>()
                simMap["subscriptionId"] = subId
                simMap["simSlotIndex"] = slotIdx // 0 for SIM 1, 1 for SIM 2
                simMap["displayName"] = dispName
                simMap["carrierName"] = carrier
                simMap["number"] = num
                list.add(simMap)
            }
        }
        return list
    }

    // PERMISSION CHECKER
    private fun hasAudioPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            checkSelfPermission(android.Manifest.permission.READ_MEDIA_AUDIO) == PackageManager.PERMISSION_GRANTED
        } else {
            checkSelfPermission(android.Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
    }

    // PERMISSION REQUESTER
    private fun requestAudioPermission() {
        Log.d("CALL_RECORDING", "requestAudioPermission called. Android SDK=${Build.VERSION.SDK_INT}")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(
                arrayOf(android.Manifest.permission.READ_MEDIA_AUDIO),
                1001
            )
        } else {
            requestPermissions(
                arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE),
                1001
            )
        }
    }

    // HELPER: EXTRACT PHONE NUMBER FROM PATH OR FILENAME
    private fun extractPhoneNumber(path: String?, fileName: String? = null): String? {
        val fullPath = path ?: ""
        val name = fileName ?: if (fullPath.isNotEmpty()) File(fullPath).name else ""
        val parentFolder = if (fullPath.isNotEmpty()) File(fullPath).parentFile?.name ?: "" else ""

        // 1. Check parent folder (e.g. Tecno/Infinix folder named after phone number)
        if (parentFolder.isNotEmpty()) {
            val parentDigits = parentFolder.filter { it.isDigit() }
            if (parentFolder.startsWith("+") || (parentDigits.length in 7..15 && !parentDigits.startsWith("202") && !parentDigits.startsWith("201") && !parentDigits.startsWith("203"))) {
                return parentFolder
            }
        }

        // 2. Check filename (e.g. Google Phone, Samsung, Xiaomi, OnePlus dialers)
        if (name.isNotEmpty()) {
            val nameWithoutExt = name.substringBeforeLast(".")

            // Match phone numbers (7 to 15 digits, optionally with leading +)
            val phoneRegex = Regex("""(\+?\d{7,15})""")
            val matches = phoneRegex.findAll(nameWithoutExt).map { it.value }.toList()

            for (match in matches) {
                val digits = match.filter { it.isDigit() }
                // Ignore 8-digit (YYYYMMDD) or 14-digit (YYYYMMDDHHMMSS) timestamps starting with 202, 201, 203
                if ((digits.length == 8 || digits.length == 14) && (digits.startsWith("202") || digits.startsWith("201") || digits.startsWith("203"))) {
                    continue
                }
                if (digits.length in 7..15) {
                    return match
                }
            }

            // Fallback: if filename has digit block >= 7
            val nameDigits = nameWithoutExt.filter { it.isDigit() }
            if (nameDigits.length >= 7) {
                return nameWithoutExt
            }
        }

        // 3. Fallback to parent folder if it contains digits
        if (parentFolder.isNotEmpty()) {
            val parentDigits = parentFolder.filter { it.isDigit() }
            if (parentDigits.length >= 7) {
                return parentFolder
            }
        }

        return null
    }

    // HELPER: CREATE RECORDING ID FOR DEDUPLICATION
    private fun createRecordingId(
        path: String?,
        uri: String?,
        lastModified: Long,
        size: Long
    ): String {
        if (!path.isNullOrBlank()) {
            return path
        }
        if (!uri.isNullOrBlank()) {
            return uri
        }
        return "$lastModified|$size"
    }

    // MAIN RECORDING DISCOVERY SCANNER
    private fun getNewRecordings(): List<Map<String, Any?>> {
        val recordings = mutableListOf<Map<String, Any?>>()
        val discoveredRecordingIds = mutableSetOf<String>()
        val discoveredPaths = mutableSetOf<String>()

        val targetSdk = applicationInfo.targetSdkVersion
        val audioGranted = hasAudioPermission()

        Log.d("CALL_RECORDING", "==================================================")
        Log.d("CALL_RECORDING", "STARTING CALL RECORDING DISCOVERY SCAN")
        Log.d("CALL_RECORDING", "Device SDK: ${Build.VERSION.SDK_INT}, Target SDK: $targetSdk")
        Log.d("CALL_RECORDING", "Audio Permission Granted: $audioGranted")

        if (!audioGranted) {
            Log.w("CALL_RECORDING", "Audio permission is not granted! Auto-triggering request permissions...")
            runOnUiThread {
                requestAudioPermission()
            }
        }

        // 1. MEDIASTORE QUERY
        try {
            Log.d("CALL_RECORDING", "Querying MediaStore.Audio.Media.EXTERNAL_CONTENT_URI...")
            val projectionList = mutableListOf(
                MediaStore.Audio.Media._ID,
                MediaStore.Audio.Media.DISPLAY_NAME,
                MediaStore.Audio.Media.SIZE,
                MediaStore.Audio.Media.DATE_ADDED,
                MediaStore.Audio.Media.DATE_MODIFIED,
                MediaStore.Audio.Media.MIME_TYPE,
                MediaStore.Audio.Media.DATA
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                projectionList.add(MediaStore.Audio.Media.RELATIVE_PATH)
            }

            val sortOrder = "${MediaStore.Audio.Media.DATE_MODIFIED} DESC"

            contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projectionList.toTypedArray(),
                null,
                null,
                sortOrder
            )?.use { cursor ->
                Log.d("CALL_RECORDING", "MediaStore Audio query returned ${cursor.count} total items.")

                val idCol = cursor.getColumnIndex(MediaStore.Audio.Media._ID)
                val nameCol = cursor.getColumnIndex(MediaStore.Audio.Media.DISPLAY_NAME)
                val sizeCol = cursor.getColumnIndex(MediaStore.Audio.Media.SIZE)
                val addedCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATE_ADDED)
                val modCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATE_MODIFIED)
                val mimeCol = cursor.getColumnIndex(MediaStore.Audio.Media.MIME_TYPE)
                val dataCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)
                val relCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    cursor.getColumnIndex(MediaStore.Audio.Media.RELATIVE_PATH)
                } else -1

                while (cursor.moveToNext()) {
                    val id = if (idCol >= 0) cursor.getLong(idCol) else -1L
                    val name = if (nameCol >= 0) cursor.getString(nameCol) ?: "" else ""
                    val size = if (sizeCol >= 0) cursor.getLong(sizeCol) else 0L
                    val dateAddedSec = if (addedCol >= 0) cursor.getLong(addedCol) else 0L
                    val dateModSec = if (modCol >= 0) cursor.getLong(modCol) else 0L
                    val mimeType = if (mimeCol >= 0) cursor.getString(mimeCol) ?: "" else ""
                    val path = if (dataCol >= 0) cursor.getString(dataCol) else null
                    val relativePath = if (relCol >= 0) cursor.getString(relCol) ?: "" else ""

                    val lastModifiedMs = if (dateModSec > 0) dateModSec * 1000L else System.currentTimeMillis()
                    val dateAddedMs = dateAddedSec * 1000L

                    val uri = ContentUris.withAppendedId(
                        MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                        id
                    ).toString()

                    val ext = name.substringAfterLast(".", "").lowercase()
                    val supportedExts = setOf("m4a", "aac", "amr", "mp3", "wav", "3gp", "opus", "ogg", "flac")

                    val isAudioExt = ext in supportedExts
                    val isAudioMime = mimeType.startsWith("audio/")

                    if (!isAudioExt && !isAudioMime) {
                        continue
                    }

                    if (path != null) {
                        val file = File(path)
                        if (file.exists() && file.length() == 0L) {
                            continue
                        }
                    }

                    val phoneNumber = extractPhoneNumber(path, name)
                    val recordingId = createRecordingId(path, uri, lastModifiedMs, size)

                    if (discoveredRecordingIds.contains(recordingId)) continue
                    if (path != null && discoveredPaths.contains(path)) continue

                    val recordingMap = HashMap<String, Any?>()
                    recordingMap["id"] = id
                    recordingMap["name"] = name
                    recordingMap["path"] = path ?: ""
                    recordingMap["uri"] = uri
                    recordingMap["size"] = size
                    recordingMap["lastModified"] = lastModifiedMs
                    recordingMap["dateAdded"] = dateAddedMs
                    recordingMap["mimeType"] = mimeType
                    recordingMap["relativePath"] = relativePath
                    recordingMap["phoneNumber"] = phoneNumber
                    recordingMap["source"] = "mediastore"

                    recordings.add(recordingMap)
                    discoveredRecordingIds.add(recordingId)
                    if (path != null) discoveredPaths.add(path)

                    Log.d("CALL_RECORDING", "Discovered MediaStore recording: name=$name, path=$path, uri=$uri, phone=$phoneNumber, size=$size, modified=$lastModifiedMs")
                }
            } ?: run {
                Log.e("CALL_RECORDING", "MediaStore query returned NULL cursor.")
            }
        } catch (e: Exception) {
            Log.e("CALL_RECORDING", "Exception during MediaStore query: ${e.message}", e)
        }

        // 2. DIRECT FILESYSTEM FALLBACK SCAN
        Log.d("CALL_RECORDING", "Starting Direct Filesystem Scan...")
        val rootStorage = Environment.getExternalStorageDirectory()
        val candidateFolders = listOf(
            "Recordings/Call Recordings",
            "Recordings/Call",
            "Recordings",
            "Music/PhoneRecord",
            "CallRecord",
            "Call Recordings",
            "MIUI/sound_recorder/call_rec",
            "Music/Recordings",
            "Sounds",
            "VoiceRecorder"
        )

        val supportedExtensions = setOf("m4a", "aac", "amr", "mp3", "wav", "3gp", "opus")

        for (relPath in candidateFolders) {
            val folder = File(rootStorage, relPath)
            if (!folder.exists() || !folder.isDirectory) {
                continue
            }
            if (!folder.canRead()) {
                Log.w("CALL_RECORDING", "Folder exists but cannot read: ${folder.absolutePath}")
                continue
            }

            Log.d("CALL_RECORDING", "Scanning direct folder: ${folder.absolutePath}")

            val filesToScan = mutableListOf<File>()
            val children = folder.listFiles() ?: continue

            for (child in children) {
                if (child.isFile) {
                    filesToScan.add(child)
                } else if (child.isDirectory && child.canRead()) {
                    val subFiles = child.listFiles()
                    if (subFiles != null) {
                        filesToScan.addAll(subFiles.filter { it.isFile })
                    }
                }
            }

            for (file in filesToScan) {
                val ext = file.extension.lowercase()
                if (ext !in supportedExtensions) continue
                if (file.length() <= 0L) continue

                val path = file.absolutePath
                val lastMod = file.lastModified()
                val size = file.length()
                val recordingId = createRecordingId(path, null, lastMod, size)

                if (discoveredRecordingIds.contains(recordingId)) continue
                if (discoveredPaths.contains(path)) continue

                val phoneNumber = extractPhoneNumber(path, file.name)
                val mimeType = when (ext) {
                    "m4a" -> "audio/mp4"
                    "aac" -> "audio/aac"
                    "amr" -> "audio/amr"
                    "mp3" -> "audio/mpeg"
                    "wav" -> "audio/wav"
                    "3gp" -> "audio/3gpp"
                    "opus" -> "audio/opus"
                    else -> "audio/$ext"
                }

                val recordingMap = HashMap<String, Any?>()
                recordingMap["name"] = file.name
                recordingMap["path"] = path
                recordingMap["uri"] = null
                recordingMap["size"] = size
                recordingMap["lastModified"] = lastMod
                recordingMap["mimeType"] = mimeType
                recordingMap["phoneNumber"] = phoneNumber
                recordingMap["source"] = "filesystem"

                recordings.add(recordingMap)
                discoveredRecordingIds.add(recordingId)
                discoveredPaths.add(path)

                Log.d("CALL_RECORDING", "Discovered FS recording: name=${file.name}, path=$path, phone=$phoneNumber, size=$size, modified=$lastMod")
            }
        }

        Log.d("CALL_RECORDING", "==================================================")
        Log.d("CALL_RECORDING", "RECORDING DISCOVERY SCAN COMPLETE. Found ${recordings.size} total recording(s).")
        Log.d("CALL_RECORDING", "==================================================")

        return recordings
    }
}



