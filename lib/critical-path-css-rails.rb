require 'critical_path_css/configuration'
require 'critical_path_css/css_fetcher'
require 'critical_path_css/rails/config_loader'

module CriticalPathCss
  CACHE_NAMESPACE = 'critical-path-css'.freeze

  def self.generate(route)
    ::Rails.cache.write(route, fetcher.fetch_route(route), namespace: CACHE_NAMESPACE, expires_in: nil)
  end

  def self.generate_all
    fetcher.fetch.each do |route, css|
      ::Rails.cache.write(route, css, namespace: CACHE_NAMESPACE, expires_in: nil)
    end
  end

  def self.generate_to_files
    fetcher.fetch.each do |route, css|
      File.open(::Rails.root.join('app', 'views', 'critical_css', (route == '/' ? '_root' : route.gsub('/', '_')) + '.html'), 'w+') do |f|
        f.write('<style>')
        f.write(css)
        f.write('</style>')
      end
    end
  end

  def self.clear(route)
    ::Rails.cache.delete(route, namespace: CACHE_NAMESPACE)
  end

  def self.clear_matched(routes)
    ::Rails.cache.delete_matched(routes, namespace: CACHE_NAMESPACE)
  end

  def self.fetch(route)
    ::Rails.cache.read(route, namespace: CACHE_NAMESPACE) || ''
  end

  def self.fetcher
    @fetcher ||= CssFetcher.new(Configuration.new(config_loader.config))
  end

  def self.config_loader
    @config_loader ||= CriticalPathCss::Rails::ConfigLoader.new
  end
end
