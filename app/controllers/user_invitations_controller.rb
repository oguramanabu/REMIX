class UserInvitationsController < ApplicationController
  before_action :require_authentication
  before_action :set_invitation, only: [ :destroy ]

  def create
    @user_invitation = Current.user.sent_invitations.build(invitation_params)

    if @user_invitation.save
      UserInvitationMailer.invitation_email(@user_invitation).deliver_now
      redirect_to settings_path, notice: "招待メールを送信しました。"
    else
      @user = Current.user
      @pending_invitations = UserInvitation.pending.includes(:invited_by).order(created_at: :desc)
      @all_users = User.order(:family_name_kanji, :given_name_kanji)
      flash.now[:alert] = "招待の送信に失敗しました。"
      render "settings/show", status: :unprocessable_entity
    end
  end

  def destroy
    @invitation.cancel!
    redirect_to settings_path, notice: "招待をキャンセルしました。"
  end

  private

  def invitation_params
    params.require(:user_invitation).permit(:email_address)
  end

  def set_invitation
    @invitation = Current.user.sent_invitations.find(params[:id])
  end
end
