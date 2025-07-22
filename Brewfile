# Brewfile - profile-aware package installation
# Respects MAC_DEV_PROFILE environment variable

# Determine which profile to use
profile = ENV.fetch('MAC_DEV_PROFILE', 'full')
config_file = File.join(__dir__, "config/#{profile}/brew.txt")

# Read packages from profile-specific config
File.readlines(config_file).each do |line|
  line = line.strip
  next if line.empty? || line.start_with?('#')

  brew line
end

# Note: Docker is installed via cask if not using Docker Desktop
# cask "docker" # Uncomment if you want Docker Desktop instead of CLI
