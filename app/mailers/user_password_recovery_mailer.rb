class UserPasswordRecoveryMailer < ApplicationMailer
  def send_email(user, origin, token)
    @token = token
    @template = fetch_email_template
    @user = user
    @body = fill_body(origin)
    mail(to: @user.email_address, subject: @template.subject)
  end

  private

  def fetch_email_template
    EmailTemplate.find_by(action: 'password_recovery')
  end

  def fill_body(origin)
    @template.body.gsub('{{nome_do_usuario}}', @user.name)
      .gsub(
        '{{link_para_atualizar_senha}}',
        "<a href='#{origin}/user-password-update/#{@user.id}?token=#{@token}&validation_type=password_recovery'>Clique aqui para atualizar sua senha.</a>"
      ).html_safe
  end
end
