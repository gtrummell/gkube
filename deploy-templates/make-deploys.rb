#!/usr/bin/env ruby

require 'json'
require 'erb'

portainer_templates = File.read('/home/gtrummell/src/gnas-portainer-templates/templates.json')
@erb_template_file = File.read('./deploy-template.yml.erb')
@template_array = JSON.parse(portainer_templates)
@portainer_list = []

def parse_portainer
  @template_array.each do |app|
    # Basic information
    name = String(app['image']).sub(/^.*\//, '').sub(':latest', '')
    image = String(app['image'])

    # Construct the Env array from portainer templates.
    env = []
    unless app['env'].nil?
      app['env'].each do |env_var|
        unless env_var['name'] == "TZ"
          env << { "var_name" => env_var['name'], "var_value" => env_var['default'] }
        end
      end
    end

    # Construct the port array
    ports = []
    unless app['ports'].nil?
      app['ports'].each do |net_port|
        ports << { "port" => net_port.split('/')[0], "protocol" => String(net_port.split('/')[1]).upcase }
      end
    end

    # Construct the Volumes array
    volumes = []
    unless app['volumes'].nil?
      app['volumes'].each do |app_volume|
        vol_name = app_volume['container'].gsub(/\//, '-').gsub(/--/, '-').gsub(/:ro/, '').sub(/^-/, '').sub(/-$/, '').downcase
        mount_path = app_volume['container'].sub(/:ro/, '')
        unless vol_name == "downloads" || vol_name == "movies" || vol_name == "tv" || vol_name == "music" || vol_name == "media" || vol_name == "files" || vol_name == "comics"
          volumes << { "name" => "#{name}-#{vol_name}", "mount_path" => mount_path }
        end
      end
    end

    app_hash = { name: name, image: image, env: env, ports: ports, volumes:volumes }

    @portainer_list.push(app_hash)

    rendered_template = ERB.new(@erb_template_file).result
    puts rendered_template
  end
end

parse_portainer

@portainer_list.uniq!
@portainer_list.sort_by!

@portainer_list.each do |item|
  puts item



end
