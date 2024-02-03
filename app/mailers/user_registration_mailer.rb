class UserRegistrationMailer < ApplicationMailer
  def send_email(user, origin)
    @template = fetch_email_template
    @user = user
    @body = fill_body(origin)
    mail(to: @user.email_address, subject: @template.subject)
  end

  private

  def fetch_email_template
    EmailTemplate.find_by(action: 'user_register')
  end

  def fill_body(origin)
    @template.body.gsub('{{nome_do_usuario}}', @user.name)
      .gsub(
        '{{link_para_ativacao_registro}}',
        "<a href='#{origin}/user_activation/#{@user.id}?token=#{create_token}&validation_type=registration'>Clique aqui para confirmar seu cadastro</a>"
      ).html_safe
  end

  def create_token
    user_validator = Validation.create!(
      user_id: @user.id,
      validation_type: 0,
      status: 0,
      token: SecureRandom.hex(20)
    )

    user_validator.token
  end
end
