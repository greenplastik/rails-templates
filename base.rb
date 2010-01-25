# Initialize variables as false
rspec = false
formtastic = false
vestal_versions = false
utility = false

# ASK ALL OF THE QUESTIONS UP FRONT
# Ask user about RSpec
if yes?("Do you want to use RSpec for testing?")
  rspec = true
end

# Ask user about Formtastic
if yes?("Do you want to use Formtastic for your forms?")
  formtastic = true
end

# Ask user about Vestal Versions
if yes?("Do you want to use Vestal Versions for model versioning?")
  vestal_versions = true
end

# Ask user about Bluecloth and Markaby
if yes?("Do you want to install utility gems (Bluecloth, Markaby, etc.)?")
  utility = true
end

# ADD SELECTED GEMS
# Add RSpec if selected
if rspec
  plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git"
  plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git"
  generate :rspec
end

# Add Formtastic and Validation Reflection if Formtastic selected
if formtastic
  gem "formtastic", :source => "http://gemcutter.org"
  gem "validation_reflection", :source => "http://gemcutter.org"
end

# Add Vestal Versions if selected
if vestal_versions
  gem "vestal_versions", :source => "http://gemcutter.org"
end

#Add utility gems if selected
if utility
  gem "bluecloth", :source => "http://gemcutter.org"
  gem "markaby", :source => "http://gemcutter.org"
  gem "linguistics", :source => "http://gemcutter.org"
  gem "will_paginate", :source => "http://gemcutter.org"
  gem "chronic", :source => "http://gemcutter.org"
end

# Add sqlite3 gem
gem 'sqlite3-ruby', :lib => 'sqlite3'

# Ensure the selected gems are installed
puts "You may need to enter your password to install the selected gems."
rake('gems:install', :sudo => true)

# RUN GENERATORS FOR SELECTED GEMS
# Generate Formtastic files
if formtastic 
  generate :formtastic
end

# Generate Vestal_Versions files
if vestal_versions
  generate :vestal_versions
  rake "db:migrate"
end

# Generate default layout
generate :nifty_layout

# Initialize git repository
git :init

# Set up project files
run "echo 'TODO add readme content' > README"
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"
run "mv public/index.html public/start.html"

# Delete unnecessary files
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm public/images/rails.png"

# Configure .gitignore files
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
file '.gitignore',
%q{
  log/*.log
  log/*.pid
  db/*.db
  db/*.sqlite3
  db/schema.rb
  tmp/**/*
  .DS_Store
  config/database.yml
}

# Add files to git repository
git :add => "."

# Initial commit
git :commit => "-m 'Initial commit'"

# Success!
puts "SUCCESS!"