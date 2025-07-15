class UserInvitationsController < ApplicationController
  before_action :require_authentication

  def create
    @user_invitation = Current.user.sent_invitations.build(invitation_params)

    if @user_invitation.save
      UserInvitationMailer.invitation_email(@user_invitation).deliver_now
      redirect_to settings_path, notice: "招待メールを送信しました。"
    else
      @user = Current.user
      @pending_invitations = @user.sent_invitations.pending.order(created_at: :desc)
      flash.now[:alert] = "招待の送信に失敗しました。"
      render "settings/show", status: :unprocessable_entity
    end
  end

  private

  def invitation_params
    params.require(:user_invitation).permit(:email_address)
  end
end
