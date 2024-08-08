module FieldsHelper
  def get_display_hour time, clock_type
    return 12 if clock_type == "am" && (time.strftime("%p") == "PM")
    return 0 if clock_type == "pm" && (time.strftime("%p") == "AM")
    if clock_type == "pm" && (time.strftime("%I") == "12")
      return (time.min / 60.0).round 1
    end

    time.strftime("%I").to_i + (time.min / 60.0).round(1)
  end

  def get_field_types
    FieldType.all.map{|field_type| [field_type.name, field_type.id]}
  end

  def first_field_type
    FieldType.first
  end

  def get_image field
    field.image.attached? ? field.image : "soccer_field.jpg"
  end

  def all_field_types
    FieldType.all
  end

  # Return true if request params contain all active params
  def active? active_params
    active_params = active_params.transform_keys(&:to_s)
                                 .transform_values(&:to_s)
                                 .to_a
    (active_params - request.query_parameters.to_a).empty?
  end

  def get_uri active_params
    unless active? active_params
      return request.query_parameters.merge(active_params)
    end

    remain_params = request.query_parameters.dup
    active_params.each_key{|key| remain_params.delete key}
    remain_params
  end
end
