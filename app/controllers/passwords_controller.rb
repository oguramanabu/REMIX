class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])

    respond_to do |format|
      format.html {
        if user
          PasswordsMailer.reset(user).deliver_later
        end
        redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
      }
      format.turbo_stream {
        if user
          PasswordsMailer.reset(user).deliver_later
          flash.now[:notice] = "パスワードリセット用のメールを送信しました。"
          render turbo_stream: [
            turbo_stream.replace("password_reset_form",
              partial: "passwords/success_message",
              locals: { message: "パスワードリセット用のメールを送信しました。メールをご確認ください。" }
            ),
            turbo_stream.append("body", "<script>setTimeout(() => { document.querySelector('[data-controller=\"modal\"]').dispatchEvent(new CustomEvent('modal:close')); }, 3000);</script>")
          ]
        else
          flash.now[:alert] = "このメールアドレスは登録されていません。"
          render turbo_stream: turbo_stream.replace("password_reset_form",
            partial: "passwords/new_form",
            locals: { alert_message: "このメールアドレスは登録されていません。" }
          )
        end
      }
    end
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      redirect_to new_session_path, notice: "Password has been reset."
    else
      redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
