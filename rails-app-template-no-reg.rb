# >----------------------------[ Initial Setup ]------------------------------<

@repo = 'https://github.com/jdugarte/rails-app-template'
@repo_raw = 'https://raw.github.com/jdugarte/rails-app-template/master/files2/'

def copy_from_repo(filename)
  source_filename = @repo_raw + filename
  destination_filename = filename
  remove_file(destination_filename) if File.exists?(destination_filename)
  begin
    get source_filename, destination_filename
  rescue OpenURI::HTTPError
    say "Unable to obtain #{filename} from the repo #{@repo}"
  end
end

# >---------------------------------[ init ]----------------------------------<

# create repository
git :init
append_file '.gitignore' do
<<-FILE
/coverage
/public/system
/public/assets
FILE
end

# commit basic rails app
git :add => "."
git :commit => "-a -m 'initial rails application'"

# >---------------------------------[ gems ]----------------------------------<

# create rvmrc file
create_file ".rvmrc", "rvm gemset use #{app_name} --create"

# add gems
gsub_file 'Gemfile', /(gem 'sqlite3')/, '# \1'
gem 'jquery-ui-rails'
gem 'devise'
gem 'rails-i18n'
gem 'globalize3'
gem "paperclip", "~> 3.0"
gem 'http_accept_language'
gem 'turbolinks'
gem 'rvm-capistrano'
gem_group :development do
  gem "debugger"
  gem 'sqlite3'
end
gem_group :test do
  gem 'simplecov', :require => false
  gem 'sqlite3'
  gem "mocha", :require => false
end
gem_group :production do
  gem "mysql2"
end

# create gemset
run "rvm rvmrc trust #{app_name}"
run "rvm gemset use #{app_name} --create"
run 'bundle install --without production'

# commit gems
git :add => "."
git :commit => "-a -m 'add gems'"

# >---------------------------------[ devise ]-----------------------------------<

generate "devise:install"
# generate "devise User"

# >---------------------------------[ files from repo ]--------------------------<

copy_from_repo "files.txt"
File.readlines('files.txt').each do |file|
  file.chomp!
  copy_from_repo(file) unless file.empty?
end
remove_file "files.txt"

# >---------------------------------[ edit files ]-------------------------------<

# app/assets/javascripts/application.js
inject_into_file 'app/assets/javascripts/application.js', :after => "//= require jquery_ujs\n" do
<<-FILE
//= require jquery.ui.sortable
//= require turbolinks
FILE
end
append_file 'app/assets/javascripts/application.js' do
<<-FILE

var triggerEvent;

$(document).ready(function() {
  return triggerEvent("page:change");
});

triggerEvent = function(name) {
  var event;
  event = document.createEvent('Events');
  event.initEvent(name, true, true);
  return document.dispatchEvent(event);
};

$(document).on('page:fetch', function(name) {
  $(".loading").show();
});
$(document).on('page:change', function(name) {
  $(".loading").hide();
});

filterTable = function(selector, query) {
  query = $.trim(query); //trim white space
  query = query.replace(/ /gi, '|'); //add OR for regex query
  $(selector).each(function() {
    ($(this).text().search(new RegExp(query, "i")) < 0) ? $(this).hide() : $(this).show();
  });
};
FILE
end

# app/assets/stylesheets/application.css
inject_into_file 'app/assets/stylesheets/application.css', :after => " *= require_self\n" do
<<-FILE
 *= require jquery.ui.selectable
FILE
end

# config/application.rb
inject_into_file 'config/application.rb', :after => "# config.i18n.default_locale = :de\n" do
<<-FILE
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
FILE
end

# config/database.yml
gsub_file 'config/database.yml', /production:.*/m do
<<-FILE
production:
  adapter: mysql2
  encoding: utf8
  username: username
  password: password
  host: localhost
  port: 3306
  database: #{app_name}
FILE
end

# config/environment.rb
append_file 'config/environment.rb' do
<<-FILE

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance| 
  if html_tag =~ /<label/
    %|<div class="fieldWithErrors">\#{html_tag} <span class="error">\#{[instance.error_message].join(', ')}</span></div>|.html_safe
  else
    html_tag
  end
end
FILE
end

# config/environments/development.rb
inject_into_file 'config/environments/development.rb', :after => "config.action_mailer.raise_delivery_errors = false\n" do 
<<-FILE
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "localhost",
    :port => 25
  }
  config.action_mailer.perform_deliveries = true
FILE
end
inject_into_file 'config/environments/development.rb', :before => "\nend" do 
<<-FILE


  # ImageMagick location, for Paperclip
  Paperclip.options[:command_path] = "/usr/local/bin/"

  # Avoid double remote calls
  config.assets.debug = true
  config.serve_static_assets = true

  # Availales locales
  config.i18n.available_locales = [:en, :es, :fr]
FILE
end

# config/environments/production.rb
gsub_file 'config/environments/production.rb', /# config\.assets\.precompile \+= %w\( search\.js \)/, 'config.assets.precompile += %w( common.css )'
inject_into_file 'config/environments/production.rb', :before => "\nend" do 
<<-FILE


  # action_mailer set up
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => '#{app_name}.sytes.net' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "localhost",
    :port => 25
  }
  config.action_mailer.perform_deliveries = true

  # ImageMagick location, for Paperclip
  Paperclip.options[:command_path] = "/usr/local/bin/"

  # Availales locales
  config.i18n.available_locales = [:en, :es, :fr]
FILE
end

# config/environments/test.rb
inject_into_file 'config/environments/test.rb', :after => "config.action_mailer.delivery_method = :test\n" do 
<<-FILE
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
FILE
end
inject_into_file 'config/environments/test.rb', :before => "\nend" do 
<<-FILE


  # Availales locales
  config.i18n.available_locales = [:en, :es, :fr]
FILE
end

# config/initializers/devise.rb
gsub_file 'config/initializers/devise.rb', /# config\.authentication_keys = \[ :email \]/, 'config.authentication_keys = [ :username ]'
gsub_file 'config/initializers/devise.rb', /\[ :email \]/, '[ :username ]'
gsub_file 'config/initializers/devise.rb', /# config\.http_authenticatable_on_xhr = true/, 'config.http_authenticatable_on_xhr = false'

# test/test_helper.rb
append_file 'test/test_helper.rb' do
<<-FILE

require 'simplecov'
SimpleCov.start

class ActionController::TestCase
  include Devise::TestHelpers
end

require "mocha/setup"

def assert_js_redirect_to_sign_in
  assert_equal "text/javascript", response.content_type
  assert_equal "window.location = '\#{new_user_session_path}'", response.body
end

FILE
end

# db/seeds.rb
append_file 'db/seeds.rb' do
<<-FILE

user = User.create :username => "admin", :name => 'Admin', :email => 'admin@local.com', :password => '123123', 
                   :password_confirmation => '123123', :admin => true
user.confirm! 

FILE
end

# APPNAME
%w{
  config/routes.rb
  app/views/layouts/application.html.erb
  config/deploy.rb
  config/locales/en.yml
  config/locales/es.yml
  config/locales/fr.yml
}.each do |file|
  gsub_file file, /APPNAME/, app_name.capitalize
end

# >---------------------------------[ clean up ]-----------------------------<

remove_file 'public/index.html'
remove_file 'app/assets/images/rails.png'

# >---------------------------------[ finish ]-------------------------------<

# migrate
rake "db:migrate"
rake "db:seed"

# commit all changes
git :add => "."
git :commit => "-a -m 'add template changes'"

