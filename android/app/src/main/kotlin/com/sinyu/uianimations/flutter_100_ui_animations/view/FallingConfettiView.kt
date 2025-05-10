package com.sinyu.uianimations.flutter_100_ui_animations.view

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.util.AttributeSet
import android.view.View
import android.view.animation.LinearInterpolator
import kotlin.math.PI
import kotlin.random.Random

class FallingConfettiView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    private val confettiPieces = mutableListOf<ConfettiPiece>()
    private val paint = Paint()
    private val random = Random
    private var animator: ValueAnimator? = null
    private var numberOfPieces: Int = 50

    private val colors = listOf(
        Color.parseColor("#FF9BC5"),
        Color.parseColor("#9383FF"),
        Color.parseColor("#7ED9FF"),
        Color.parseColor("#7FD8FF")
    )

    init {
        // 初始化ValueAnimator用于动画更新
        setupAnimator()
    }

    fun setNumberOfPieces(count: Int) {
        numberOfPieces = count
        resetConfetti()
    }

    private fun setupAnimator() {
        animator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 16 // 接近16ms的刷新率，约60FPS
            repeatCount = ValueAnimator.INFINITE
            repeatMode = ValueAnimator.RESTART
            interpolator = LinearInterpolator()
            addUpdateListener {
                updateConfettiPositions()
                invalidate()
            }
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        animator?.start()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        animator?.cancel()
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        resetConfetti()
    }

    private fun resetConfetti() {
        confettiPieces.clear()
        if (width > 0 && height > 0) {
            generateConfetti()
        }
    }

    private fun generateConfetti() {
        repeat(numberOfPieces) {
            val pieceWidth = random.nextDouble(10.0, 20.0).toFloat()
            val pieceHeight = pieceWidth * (0.5f + random.nextDouble(0.0, 0.3).toFloat())
            confettiPieces.add(
                ConfettiPiece(
                    color = colors[random.nextInt(colors.size)],
                    width = pieceWidth,
                    height = pieceHeight,
                    angle = random.nextDouble(0.0, 2.0 * PI).toFloat(),
                    x = random.nextDouble(0.0, width.toDouble()).toFloat(),
                    y = random.nextDouble(-height.toDouble(), height.toDouble()).toFloat(),
                    speed = random.nextDouble(1.0, 3.0).toFloat()
                )
            )
        }
    }

    private fun updateConfettiPositions() {
        confettiPieces.forEach { piece ->
            piece.y += piece.speed
            if (piece.y > height) {
                piece.y = -piece.height
                piece.x = random.nextDouble(0.0, width.toDouble()).toFloat()
            }
        }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        confettiPieces.forEach { piece ->
            if (piece.y >= -piece.height && piece.y <= height) {
                paint.color = piece.color
                
                canvas.save()
                canvas.translate(piece.x, piece.y)
                canvas.rotate(Math.toDegrees(piece.angle.toDouble()).toFloat())
                
                val rect = Rect(
                    -(piece.width / 2).toInt(),
                    -(piece.height / 2).toInt(),
                    (piece.width / 2).toInt(),
                    (piece.height / 2).toInt()
                )
                canvas.drawRect(rect, paint)
                
                canvas.restore()
            }
        }
    }

    data class ConfettiPiece(
        val color: Int,
        val width: Float,
        val height: Float,
        val angle: Float,
        var x: Float,
        var y: Float,
        val speed: Float
    )
} 