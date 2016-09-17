module DisableDoubleClickOnSimpleForms
  def submit(field, options = {})
    if field.is_a?(Hash)
      field[:data] ||= {}
      field[:data][:disable_with] ||= field[:value] || 'Processing...'
    else
      options[:data] ||= {}
      options[:data][:disable_with] ||= options[:value] || 'Processing...'
    end
    super(field, options)
  end
end

SimpleForm::FormBuilder.prepend(DisableDoubleClickOnSimpleForms)
