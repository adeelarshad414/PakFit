package com.pakfit.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.pakfit.app.ui.PakFitApp
import com.pakfit.app.ui.PakFitTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            PakFitTheme {
                PakFitApp()
            }
        }
    }
}
