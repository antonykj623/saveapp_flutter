package com.mysave

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.ContactsContract
import android.speech.RecognizerIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.app.AlertDialog
import java.util.Locale
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.contactpicker/channel"
    private val VOICE_CHANNEL = "com.example.voicesearch/channel"
    private val FILE_CHANNEL = "com.mysave.filemanager/channel"
    
    private val PICK_CONTACT = 1
    private val SPEECH_REQUEST_CODE = 2
    private val SAVE_FILE_REQUEST_CODE = 3
    private val OPEN_FILE_REQUEST_CODE = 4
    
    private var resultCallback: MethodChannel.Result? = null
    private var voiceResultCallback: MethodChannel.Result? = null
    private var fileResultCallback: MethodChannel.Result? = null
    
    private var tempFilePath: String? = null
    private var tempFileName: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Contact Picker Channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "pickContact") {
                resultCallback = result
                val contactIntent = Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI)
                startActivityForResult(contactIntent, PICK_CONTACT)
            } else {
                result.notImplemented()
            }
        }

        // Voice Search Channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, VOICE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVoiceSearch" -> {
                    voiceResultCallback = result
                    startVoiceRecognition()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // File Manager Channel (NEW)
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, FILE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveBackupFile" -> {
                    fileResultCallback = result
                    val fileName = call.argument<String>("fileName") ?: "MySaving_Backup.json"
                    val filePath = call.argument<String>("filePath") ?: ""
                    
                    tempFileName = fileName
                    tempFilePath = filePath
                    
                    saveFileToStorage(fileName)
                }
                "openBackupFile" -> {
                    fileResultCallback = result
                    openFileFromStorage()
                }
                else -> {
                    result.notImplemented()
                }
            }  
        }
    }

    private fun saveFileToStorage(fileName: String) {
        try {
            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/json"
                putExtra(Intent.EXTRA_TITLE, fileName)
            }
            startActivityForResult(intent, SAVE_FILE_REQUEST_CODE)
        } catch (e: Exception) {
            fileResultCallback?.error("FILE_ERROR", "Failed to open file picker: ${e.message}", null)
            fileResultCallback = null
        }
    }

    private fun openFileFromStorage() {
        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/json"
            }
            startActivityForResult(intent, OPEN_FILE_REQUEST_CODE)
        } catch (e: Exception) {
            fileResultCallback?.error("FILE_ERROR", "Failed to open file picker: ${e.message}", null)
            fileResultCallback = null
        }
    }

    private fun startVoiceRecognition() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
            putExtra(RecognizerIntent.EXTRA_PROMPT, "Say contact name to search...")
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
        }

        try {
            startActivityForResult(intent, SPEECH_REQUEST_CODE)
        } catch (e: Exception) {
            voiceResultCallback?.error("SPEECH_NOT_AVAILABLE", "Speech recognition not available", null)
            voiceResultCallback = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        when (requestCode) {
            PICK_CONTACT -> handleContactPicker(resultCode, data)
            SPEECH_REQUEST_CODE -> handleVoiceRecognition(resultCode, data)
            SAVE_FILE_REQUEST_CODE -> handleSaveFile(resultCode, data)
            OPEN_FILE_REQUEST_CODE -> handleOpenFile(resultCode, data)
        }
    }

    private fun handleContactPicker(resultCode: Int, data: Intent?) {
        if (resultCode == Activity.RESULT_OK) {
            val contactUri: Uri? = data?.data
            val cursor = contentResolver.query(contactUri!!, null, null, null, null)
            
            if (cursor != null && cursor.moveToFirst()) {
                val name = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME))
                val id = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID))
                var phoneNumber: String? = null

                val hasPhoneNumber = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.HAS_PHONE_NUMBER))

                if (hasPhoneNumber == "1") {
                    val phonesCursor = contentResolver.query(
                        ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                        null,
                        "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?",
                        arrayOf(id),
                        null
                    )

                    if (phonesCursor != null && phonesCursor.moveToFirst()) {
                        phoneNumber = phonesCursor.getString(
                            phonesCursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.NUMBER)
                        )
                        phonesCursor.close()
                    }
                }

                cursor.close()
                resultCallback?.success("$name,$phoneNumber")
            } else {
                resultCallback?.success("No contact found")
            }
        } else {
            resultCallback?.success("Contact picker cancelled")
        }
        resultCallback = null
    }

    private fun handleVoiceRecognition(resultCode: Int, data: Intent?) {
        if (resultCode == Activity.RESULT_OK && data != null) {
            val results = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            if (!results.isNullOrEmpty()) {
                val spokenText = results[0]
                voiceResultCallback?.success(spokenText)
            } else {
                voiceResultCallback?.error("NO_SPEECH", "No speech detected", null)
            }
        } else {
            voiceResultCallback?.error("CANCELLED", "Voice search cancelled", null)
        }
        voiceResultCallback = null
    }

    private fun handleSaveFile(resultCode: Int, data: Intent?) {
        if (resultCode == Activity.RESULT_OK && data?.data != null) {
            try {
                val uri = data.data!!
                val sourceFile = File(tempFilePath ?: "")
                
                if (!sourceFile.exists()) {
                    fileResultCallback?.error("FILE_ERROR", "Source file not found", null)
                    fileResultCallback = null
                    return
                }

                // Copy file to selected location
                contentResolver.openOutputStream(uri)?.use { outputStream ->
                    sourceFile.inputStream().use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }

                // Delete temp file
                sourceFile.delete()
                
                fileResultCallback?.success("success")
            } catch (e: Exception) {
                fileResultCallback?.error("FILE_ERROR", "Failed to save file: ${e.message}", null)
            }
        } else {
            fileResultCallback?.success("cancelled")
        }
        fileResultCallback = null
    }

    private fun handleOpenFile(resultCode: Int, data: Intent?) {
        if (resultCode == Activity.RESULT_OK && data?.data != null) {
            try {
                val uri = data.data!!
                
                // Copy selected file to app's temp directory
                val tempDir = cacheDir
                val tempFile = File(tempDir, "temp_restore_backup.json")
                
                contentResolver.openInputStream(uri)?.use { inputStream ->
                    FileOutputStream(tempFile).use { outputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                
                fileResultCallback?.success(tempFile.absolutePath)
            } catch (e: Exception) {
                fileResultCallback?.error("FILE_ERROR", "Failed to read file: ${e.message}", null)
            }
        } else {
            fileResultCallback?.success("cancelled")
        }
        fileResultCallback = null
    }

    private fun showSimpleDialog(message: String) {
        AlertDialog.Builder(this)
            .setTitle("Hello!")
            .setMessage(message)
            .setPositiveButton("OK") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
    }
}