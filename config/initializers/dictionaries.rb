Dictionaries = OpenStruct.new(YAML.load(File.read(File.join(Rails.root, "config", "dictionaries.yml"))))
