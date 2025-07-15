class UserActivationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @token = params[:token]
    @user_invitation = UserInvitation.find_by(token: @token)

    if @user_invitation.nil?
      redirect_to new_session_path, alert: "無効な招待リンクです。"
      return
    end

    if @user_invitation.cancelled?
      redirect_to new_session_path, alert: "この招待はキャンセルされています。"
      return
    end

    if @user_invitation.expired?
      redirect_to new_session_path, alert: "招待リンクの有効期限が切れています。"
      return
    end

    if @user_invitation.accepted?
      redirect_to new_session_path, alert: "この招待は既に使用されています。"
      return
    end

    @user = User.new(email_address: @user_invitation.email_address)
  end

  def create
    @token = params[:token]
    @user_invitation = UserInvitation.find_by(token: @token)

    if @user_invitation.nil? || @user_invitation.cancelled? || @user_invitation.expired? || @user_invitation.accepted?
      redirect_to new_session_path, alert: "無効な招待リンクです。"
      return
    end

    @user = User.new(user_params)
    @user.email_address = @user_invitation.email_address

    if @user.save
      @user_invitation.accept!

      session = @user.sessions.create!(
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      cookies.signed[:session_id] = { value: session.id, httponly: true, same_site: :lax }

      redirect_to root_path, notice: "アカウントが作成されました。ようこそ！"
    else
      flash.now[:alert] = "アカウント作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:family_name_eng, :given_name_eng, :family_name_kanji, :given_name_kanji, :password, :password_confirmation)
  end
end
