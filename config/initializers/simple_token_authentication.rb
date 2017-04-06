SimpleTokenAuthentication.configure do |config|
  config.sign_in_token = true
  config.header_names = { user: { authentication_token: 'X-User-Token', email: 'X-User-Email' } }
end