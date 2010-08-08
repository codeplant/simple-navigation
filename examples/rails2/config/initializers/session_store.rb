# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_simple_navigation_examples_session',
  :secret      => 'd2a1702d3a59ca94998901bf93fe6de12dc7fe767c6bfdb9d30e87e170891e3e18f348b3580891e173afdf05c18ce57aa4392c6d0e7b543ade5d2424237eb754'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
