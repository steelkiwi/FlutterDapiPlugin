package com.steelkiwi.dapi_plugin

import android.os.Build
import android.os.Bundle
import androidx.annotation.RequiresApi
import io.flutter.app.FlutterActivity

class DapiConnectActivity : FlutterActivity() {
//    private var progressDialog: ProgressDialog? = null


    companion object {
        const val REQUEST_VIDEO_TRIMMER = 1
        internal const val EXTRA_INPUT_URI = "EXTRA_INPUT_URI"
        internal const val EXTRA_INPUT_MAX_SECONDS = "EXTRA_INPUT_MAX_SECONDS"
        internal const val EXTRA_OUTPUT_FILE = "EXTRA_OUTPUT_FILE"
//        private val allowedVideoFileExtensions = arrayOf("mkv", "mp4", "3gp", "mov", "mts")
//        private val videosMimeTypes = ArrayList<String>(allowedVideoFileExtensions.size)
    }

    @RequiresApi(Build.VERSION_CODES.FROYO)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_trimmer)
//        var  videoTrimingView=findViewById<VideoTrimmerView>(R.id.videoTrimmerView);
//        videoTrimingView.onCancelListener={
//            setResult(Activity.RESULT_CANCELED, intent)
//            finish()
//        };
//        val inputVideoUri: String? = intent?.getStringExtra(EXTRA_INPUT_URI)
//        val maxSeconds: Double? = intent?.getDoubleExtra(EXTRA_INPUT_MAX_SECONDS, 15.0) ?: 15.0;
//        if (inputVideoUri == null) {
//            finish()
//            return
//        }
//        //setting progressbar
//        if (maxSeconds != null) {
//            videoTrimmerView.setMaxDurationInMs((maxSeconds * 1000).toInt())
//        }
//
//        videoTrimmerView.setOnK4LVideoListener(this)
//        val parentFolder = getExternalFilesDir(null)!!
//        parentFolder.mkdirs()
//        val fileName = "trimmedVideo_${System.currentTimeMillis()}.mp4"
//        val trimmedVideoFile = File(parentFolder, fileName)
//        videoTrimmerView.setDestinationFile(trimmedVideoFile)
//        videoTrimmerView.setVideoURI(Uri.fromFile(File(inputVideoUri)))
//
//        videoTrimmerView.setVideoInformationVisibility(true)
    }


}
