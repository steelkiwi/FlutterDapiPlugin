package com.steelkiwi.dapi_plugin.model

class AuthState(public var accessId: String? = null, public var bankId: String? = null, public var status: AuthStatus, var error: String? = null)