module UsersHelper
  def admin
    @admin = User.find_by admin: true
  end

  def activated_class activated
    activated ? "text-green-500" : "text-red-500"
  end
end
