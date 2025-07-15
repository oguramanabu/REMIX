class UserInvitationMailer < ApplicationMailer
  def invitation_email(user_invitation)
    @user_invitation = user_invitation
    @invited_by = user_invitation.invited_by
    @activation_url = activate_user_invitation_url(@user_invitation.token)

    mail(
      to: @user_invitation.email_address,
      subject: "【Catallaxy】アカウント招待のお知らせ"
    )
  end
end
