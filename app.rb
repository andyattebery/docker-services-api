require 'docker'
require 'http'
require 'json'
require 'yaml'
require 'sinatra/base'
require 'sinatra/json'
# require 'sinatra/config_file'

require_relative 'config'
require_relative 'dashboard_managers/dashy_dashboard_manager'
require_relative 'service_providers/docker_service_provider'

class DockerServicesApi < Sinatra::Base

  def initialize(app = nil, **kwargs)
    super(app, **kwargs)

    @config = Config.new
    @service_provider = DockerServiceProvider.new(@config)
    @dashboard_manager = DashyDashboardManager.new(@config)

    yield self if block_given?
  end

  get "/services" do
    services = @service_provider.get_services
    json services.to_json
  end

  get "/dashboard-config" do
    headers "Content-Type" => "text/x.yaml"
    dashboard_config_hash = @dashboard_manager.get_sections_hash
    dashboard_config_hash.to_yaml
  end

  get "/update-dashboard-config" do
    headers "Content-Type" => "text/x.yaml"
    services = @service_provider.get_services
    updated_sections = @dashboard_manager.save_to_config_file(services)
    updated_sections.to_yaml
  end

end