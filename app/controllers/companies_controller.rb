# frozen_string_literal: true

class CompaniesController < AddressableController
  def model_params
    params.require(:company).permit(:user_id, :email_address)
  end

  def addressable_params
    params
      .permit(:street, :number, :neighborhood, :city, :state)
      .merge({ addressable_id: params[:company_id], addressable_type: 'Company' })
  end
end
