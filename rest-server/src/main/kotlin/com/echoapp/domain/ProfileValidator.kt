package com.echoapp.domain

class ProfileValidator : Validator<UserUpdate> {
    companion object {
        const val MIN_PASSWORD_LENGTH = 8
    }

    override fun validate(subject: UserUpdate): ValidationResult {
        val errors = mutableMapOf<String, String>()

        subject.firstName?.let {
            if (it.isBlank()) errors["firstName"] = "First name cannot be blank"
        }
        
        subject.lastName?.let {
            if (it.isBlank()) errors["lastName"] = "Last name cannot be blank"
        }
        
        subject.displayName?.let {
            if (it.isBlank()) errors["displayName"] = "Display name cannot be blank"
        }

        subject.email?.let {
            if (it.isBlank()) errors["email"] = "Email cannot be blank"
            else if (!it.contains("@")) errors["email"] = "[$it] is not a valid email address"
        }
        
        subject.password?.let {
            if (it.length < MIN_PASSWORD_LENGTH) errors["password"] = "Password must be at least $MIN_PASSWORD_LENGTH characters"
        }

        return if (errors.isEmpty()) {
            ValidationResult.Valid
        } else {
            ValidationResult.Invalid(errors = errors)
        }
    }
}
