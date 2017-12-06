# frozen_string_literal: true
Encryptor.default_options.merge!(
  algorithm: 'aes-256-gcm',
  key: Base64.decode64(ENV['ENCRYPT_SECRET_KEY']),
  iv: Base64.decode64(ENV['ENCRYPT_IV']),
  salt: Base64.decode64(ENV['ENCRYPT_SALT'])
)