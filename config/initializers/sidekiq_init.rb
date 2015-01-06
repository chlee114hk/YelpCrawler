datastore_config = YAML.load(ERB.new(File.read(File.join(Rails.root, "config", "redis.yml"))).result)

datastore_config = datastore_config["defaults"].merge(datastore_config[::Rails.env])

if datastore_config[:host].is_a?(Array)
  if datastore_config[:host].length == 1
    datastore_config[:host] = datastore_config[:host].first
  else
    datastore_config = datastore_config[:host].map do |host|
      host_has_port = host =~ /:\d+\z/

      if host_has_port
        "redis://#{host}/#{datastore_config[:db] || 0}"
      else
        "redis://#{host}:#{datastore_config[:port] || 6379}/#{datastore_config[:db] || 0}"
      end
    end
  end
end
  
Sidekiq.configure_server do |config|
  config.redis = ::ConnectionPool.new(:size => Sidekiq.options[:concurrency] + 2, :timeout => 2) do
    redis = if datastore_config.is_a? Array
      Redis::Distributed.new(datastore_config)
    else
      Redis.new(datastore_config)
    end

    Redis::Namespace.new('resque', :redis => redis)
  end
end