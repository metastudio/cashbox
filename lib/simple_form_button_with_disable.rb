module SimpleFormButtonWithDisable
  def submit_with_disable(*args, &block)
    options = args.extract_options!
    options[:data] ||= {}
    options[:data][:disable_with] ||= options[:value] || 'Processing...'
    args << options

    submit(*args, &block)
  end
end

SimpleForm::FormBuilder.send :include, SimpleFormButtonWithDisable
