require 'date'
# Load base template
load_template "http://github.com/greenplastik/rails-templates/raw/master/base.rb"

# Initialize variables as false
name = ''
authlogic = false
cancan = false
extra = false

# ASK ALL OF THE QUESTIONS UP FRONT
# Ask for name of user model
name = ask("What do you want a user to be called? (Default: user)")

# Ask user about Authlogic
if yes?("Do you want to use Authlogic for authentication?")
  authlogic = true
end

# Ask user about Authlogic extra functionality
if authlogic
  if yes?("Do you want the Authlogic extra functionality? (e.g.: login counts, IP adderess logging, etc.)")
    extra = true
  end
end

# Ask user about CanCan authorization and create initial abilities setup
if yes?("Do you want to use CanCan for authorization?")
  cancan = true
end

# ADD AUTHENTICATION AND, IF SELECTED, AUTHLOGIC AND CANCAN AUTHORIZATION  
if authlogic
  gem "authlogic", :source => "http://gemcutter.org"
  generate("nifty_authentication #{name} --authlogic")
else
  generate :nifty_authentication, name
end

rake "db:migrate"

if extra
  file "db/migrate/#{ Time.utc(*(Time.now - 100).to_a).strftime("%Y%m%d%H%M%S")}_add_extra_columns_to_#{name.tableize}.rb",
  "class AddExtraColumnsTo#{name.tableize.titleize} < ActiveRecord::Migration
  def self.up
    change_table :#{name.tableize} do |t|
    t.integer :login_count, :null => false, :default => 0
    t.integer :failed_login_count, :null => false, :default => 0
    t.datetime :last_request_at
    t.datetime :current_login_at
    t.datetime :last_login_at
    t.string :current_login_ip
    t.string :last_login_ip
  end
end

def self.down
  change_table :#{name.tableize} do |t|
  t.remove  :login_count, :failed_login_count, :last_request_at, 
  :current_login_at, :last_login_at, :current_login_ip, :last_login_ip
end
end
end"
end

if cancan
  gem "cancan", :source => "http://gemcutter.org"
  file 'app/models/ability.rb', 
  "class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= #{name}.new # create guest user
    can :read, :all

    case user.role.to_sym
    when :admin
      can :manage, :all 
    when :moderator
      can [:update, :read], :all
    when :user
      can :read, :all
    end
  end
end"

# Add role field to user account (creates current UTC timestamp for migration file name)
file "db/migrate/#{ Time.utc(*(Time.now).to_a).strftime("%Y%m%d%H%M%S")}_add_role_to_#{name.tableize}.rb",
"class AddRoleTo#{name.tableize.titleize} < ActiveRecord::Migration
def self.up
  add_column :#{name.tableize}, :role, :string, :default => 'user', :null => false
end

def self.down
  remove_column :#{name.tableize}, :role
end
end"
end

# Ensure the selected gems are installed
puts "You may need to enter your password to install the selected gems."
rake('gems:install', :sudo => true)

rake "db:migrate"

git :add => "." 

git :commit => "-m 'adding authentication'"

# Success!
puts "SUCCESS!"