class SettingsController < ApplicationController
  before_action :require_authentication

  def show
    @user = Current.user
    @user_invitation = UserInvitation.new
    @pending_invitations = UserInvitation.pending.includes(:invited_by).order(created_at: :desc)
    @all_users = User.order(:family_name_kanji, :given_name_kanji)
  end

  def update
    @user = Current.user

    if params[:user][:password].present?
      update_password
    elsif params[:user][:avatar].present?
      update_avatar
    else
      redirect_to settings_path, alert: "変更する項目を選択してください。"
    end
  end

  private

  def update_password
    if @user.authenticate(params[:user][:current_password])
      if @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
        redirect_to settings_path, notice: "パスワードが正常に更新されました。"
      else
        flash.now[:alert] = "パスワードの更新に失敗しました。"
        render :show, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "現在のパスワードが正しくありません。"
      render :show, status: :unprocessable_entity
    end
  end

  def update_avatar
    if @user.update(avatar: params[:user][:avatar])
      redirect_to settings_path, notice: "アバターが正常に更新されました。"
    else
      flash.now[:alert] = "アバターの更新に失敗しました。"
      render :show, status: :unprocessable_entity
    end
  end
end
