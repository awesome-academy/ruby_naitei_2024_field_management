module FieldsHelper
  def get_am_start_time started_time
    started_time.hour + started_time.min / 60.0
  end

  def get_am_end_time finished_time
    if finished_time.hour < 12
      finished_time.hour + finished_time.min / 60.0
    else
      12
    end
  end

  def get_pm_start_time started_time
    if started_time.hour > 13
      started_time.strftime("%I").to_i + started_time.min / 60.0
    else
      0
    end
  end

  def get_pm_end_time finished_time
    hour = finished_time.strftime("%I").to_i
    (hour == 12 ? 0 : hour) + finished_time.min / 60.0
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
