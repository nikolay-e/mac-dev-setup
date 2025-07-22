# Brewfile - now reads from config/brew.txt for better maintainability
# This file is kept for backwards compatibility with existing setups

# Read packages from config/brew.txt
File.readlines(File.join(__dir__, 'config/brew.txt')).each do |line|
  line = line.strip
  next if line.empty? || line.start_with?('#')

  brew line
end

# Note: Docker is installed via cask if not using Docker Desktop
# cask "docker" # Uncomment if you want Docker Desktop instead of CLI
