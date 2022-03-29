package com.namit.presentation_displays

import androidx.annotation.Keep
import com.google.gson.annotations.SerializedName

@Keep
data class DisplayJson(
    @SerializedName("displayId")
    val displayId: Int,
    @SerializedName("flags")
    val flags: Int,
    @SerializedName("rotation")
    val rotation: Int,
    @SerializedName("name")
    val name: String
)
