module ApplicationHelper
  include Pagy::Frontend

  def full_title title
    base_title = t "app_name"
    title.blank? ? base_title : "#{title} | #{base_title}"
  end

  def exchange_money amount
    number_to_currency(amount * t("number.money.exchange_rate"))
  end

  def sortable column, title = nil
    title ||= column.to_s.titleize
    is_current_column = column.to_s == params[:sort_column]
    direction = if is_current_column && params[:sort_direction] == "desc"
                  "asc"
                else
                  "desc"
                end
    icon = sort_icon(is_current_column, params[:sort_direction])

    link_to(sort_url(column, direction)) do
      safe_join([title, icon])
    end
  end

  def get_profile_image user
    user.image.attached? ? user.image : "avatar.jpg"
  end

  private

  def sort_url column, direction
    url_for(request.query_parameters.merge(sort_column: column,
                                           sort_direction: direction))
  end

  def sort_icon is_current_column, direction
    return "" unless is_current_column

    icon_class = "ml-1 text-sm transition-transform duration-200 ease-in-out"
    icon_class += " transform rotate-180" if direction == "asc"

    fa_icon("sort-down", class: icon_class)
  end
end
