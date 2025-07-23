module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Get the session token from cookies
      session_id = cookies.signed[:session_id]
      return reject_unauthorized_connection unless session_id

      # Find the session and associated user
      session = Session.find_by(id: session_id)
      return reject_unauthorized_connection unless session

      session.user
    end
  end
end
