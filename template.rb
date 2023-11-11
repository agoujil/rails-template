def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def copy_templates
  directory "app", force: true
end

def copy_routes
  copy_file "#{__dir__}/config/routes.rb", "config/routes.rb", force: true
end

def copy_locales
  copy_file "#{__dir__}/config/locales", "config/locales/devise.en.yml", force: true
end
def add_gems
  gem 'devise'
  gem "jsbundling-rails"
  gem "cssbundling-rails"
end

def setup_auth
  generate "devise:install"

  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",env: 'development'

  generate :devise, "User", "name"

end
def setup_bootstrap
  rails_command "css:install:bootstrap"
  copy_file "#{__dir__}/Procfile.dev", "Procfile.dev", force: true
end

def remove_importmaps
  if File.exist?("config/importmap.rb")
    run "bundle remove importmap-rails"
    remove_file "config/importmap.rb"
    remove_file "app/javascript/application.js"
    remove_file "app/javascript/controllers/index.js"
    remove_file "app/javascript/controllers/application.js"
    remove_file "app/javascript/controllers/hello_controller.js"


    say "Remove javascript_import_tags helper"
    gsub_file "app/views/layouts/application.html.erb", "<%= javascript_importmap_tags %>", ""

    say "Remove bin/importmap"
    remove_file "bin/importmap"
  end
end

def add_webpack
  rails_command "javascript:install:webpack", force: true
  app_layout_path = "app/views/layouts/application.html.erb"
  if File.exist?(app_layout_path)
    say "Add JavaScript include tag in application layout"
    insert_into_file app_layout_path.to_s,
      %(\n    <%= javascript_include_tag "application", "data-turbo-track": "reload", defer: true %>), before: /\s*<\/head>/
  else
    say "Default application.html.erb is missing!", :red
    say %(        Add <%= javascript_include_tag "application", "data-turbo-track": "reload", defer: true %> within the <head> tag in your custom layout.)
  end
  
  run "yarn add @hotwired/turbo-rails"
  run "yarn add @hotwired/stimulus"
  copy_file "#{__dir__}/application.js", "app/javascript/application.js", force: true

  run "gem install foreman"
end

def copy_templates
  directory "app", force: true
end

add_gems

after_bundle do
  remove_importmaps
  add_webpack
  setup_bootstrap
  setup_auth
  copy_templates
  copy_routes
  copy_locales
end
