module ErrorItemsHelper
  def error_items(form, field)
    form.object.errors&.full_messages_for(field)&.first if form.object.errors.key?(field)
  end
end
