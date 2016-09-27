DEFAULT_VALUES = ActiveSupport::HashWithIndifferentAccess.new(
  YAML.load_file(
    File.join(Rails.root, 'config', 'default_values.yml')
  )
)
