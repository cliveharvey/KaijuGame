#!/usr/bin/env ruby

require 'securerandom'

puts "🦖 Kaiju Defense Force - Environment Setup"
puts "=" * 50

# Generate a secure session secret
session_secret = SecureRandom.hex(32)

# Create .env file content
env_content = <<~ENV
  # Kaiju Defense Force - Environment Variables
  # Generated on #{Time.now}

  # Session secret for secure cookie signing (32 bytes)
  SESSION_SECRET=#{session_secret}

  # Optional: Set port (defaults to 4567)
  # PORT=4567

  # Optional: Set environment (development, production)
  # RACK_ENV=development
ENV

# Write to .env file
File.write('.env', env_content)

puts "✅ Created .env file with secure session secret"
puts "🔒 Session secret: #{session_secret[0..15]}... (truncated for security)"
puts ""
puts "🚀 You can now start the server with:"
puts "   bundle exec ruby app.rb"
puts ""
puts "⚠️  IMPORTANT: Never commit the .env file to version control!"
puts "   It's already added to .gitignore for safety."
