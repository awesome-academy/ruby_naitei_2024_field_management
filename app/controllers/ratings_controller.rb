class RatingsController < ApplicationController
  before_action :logged_in_user
  before_action :find_field_by_id, only: :create
  before_action :load_rating, only: %i(update destroy)
  before_action :load_field_in_rating, only: %i(update destroy)

  def index; end

  def show; end

  def new; end

  def create
    @rating = current_user.ratings.build(
      field_id: params[:field],
      **rating_params
    )
    if @rating.save
      flash["success"] = t ".success"
    else
      flash["danger"] = t ".failed"
    end
    redirect_to @field
  end

  def edit; end

  def update
    if @rating.update rating_params
      flash["success"] = t ".success"
    else
      flash["danger"] = t ".failed"
    end
    redirect_to @field
  end

  def destroy
    if @rating.destroy
      flash["success"] = t ".success"
    else
      flash["danger"] = t ".danger"
    end
    redirect_to @field
  end

  private

  def rating_params
    params.require(:rating).permit Rating::PERMITTED_ATTRIBUTES
  end

  def load_field_in_rating
    @field = @rating.field
  end
end
