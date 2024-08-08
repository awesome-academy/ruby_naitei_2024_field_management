module OrdersHelper
  def get_vouchers
    if current_user.vouchers.count.zero?
      return [t("orders.voucher_form.no_voucher"), 0]
    end

    result = current_user.vouchers.ordered_by_type_amount.map do |voucher|
      value = if voucher.voucher_type == "percent"
                "#{(voucher.amount * 100).round}%"
              else
                "-#{exchange_money(voucher.amount)}"
              end
      [value, voucher.id]
    end
    result.unshift [t("orders.voucher_form.select_voucher"), 0]
  end

  def can_delete? order
    order.pending? || order.cancelling?
  end

  def order_status_class status
    case status
    when "approved"
      "text-green-500"
    when "pending"
      "text-yellow"
    when "cancelling"
      "text-orange-500"
    when "cancel"
      "text-red-500"
    else
      "text-gray-500"
    end
  end
end
