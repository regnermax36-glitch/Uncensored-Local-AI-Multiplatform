package com.portableai.portable_ai_flutter

import android.service.voice.VoiceInteractionSessionService
import android.service.voice.VoiceInteractionSession
import android.os.Bundle
import android.content.Intent

class AssistantSessionService : VoiceInteractionSessionService() {
    override fun onNewSession(args: Bundle?): VoiceInteractionSession {
        return AssistantSession(this)
    }
}

class AssistantSession(context: android.content.Context) : VoiceInteractionSession(context) {
    override fun onShow(args: Bundle?, showFlags: Int) {
        super.onShow(args, showFlags)
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("isAssistant", true)
        }
        context.startActivity(intent)
        finish()
    }
}
