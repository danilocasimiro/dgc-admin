# frozen_string_literal: true

class UsersController < AddressableController
  def model_params
    params.require(:user).permit(:email_address, :name).merge(password: params[:password])
  end

  def addressable_params
    params
      .permit(:street, :number, :neighborhood, :city, :state)
      .merge({ addressable_id: params[:user_id], addressable_type: 'User' })
  end
end
