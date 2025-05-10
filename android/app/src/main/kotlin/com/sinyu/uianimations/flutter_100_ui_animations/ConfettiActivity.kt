package com.sinyu.uianimations.flutter_100_ui_animations

import android.os.Bundle
import android.widget.SeekBar
import androidx.appcompat.app.AppCompatActivity
import com.sinyu.uianimations.flutter_100_ui_animations.view.FallingConfettiView

class ConfettiActivity : AppCompatActivity() {

    private lateinit var confettiView: FallingConfettiView
    private lateinit var seekBarConfettiCount: SeekBar

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_confetti)
        
        confettiView = findViewById(R.id.confetti_view)
        seekBarConfettiCount = findViewById(R.id.seekbar_confetti_count)
        
        // 设置默认彩带数量
        confettiView.setNumberOfPieces(seekBarConfettiCount.progress)
        
        // 监听SeekBar变化控制彩带数量
        seekBarConfettiCount.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                confettiView.setNumberOfPieces(progress)
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {}

            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
    }
} 