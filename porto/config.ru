require "sinatra"

configure do
  # set :protection, :except => [:path_traversal, :remote_token, :bind, :host_authorization]
  set :host_authorization, :permitted_hosts => []
end

require_relative "./app"
run Sinatra::Application
