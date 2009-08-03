class IpGeolocationGenerator < Rails::Generator::NamedBase
  attr_accessor :migration_name

  def initialize(args, options = {})
    super
  end

  def manifest
    file_name = generate_file_name
    @migration_name = file_name.camelize
    record do |m|
      m.migration_template "ip_geolocation_migration.rb.erb",
                           File.join('db', 'migrate'),
                           :migration_file_name => file_name
    end
  end

  private

  def generate_file_name   
    "add_ip_geolocation"
  end

end
