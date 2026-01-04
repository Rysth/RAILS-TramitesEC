class Api::V1::Users::TokensController < Devise::Api::TokensController
  # Normalize params, check active flag, then let Devise handle authentication
  def sign_in
    creds = extracted_sign_in_params
    user = User.find_by(email: creds[:email])

    if user.nil?
      render json: { error: 'Credenciales inválidas.' }, status: :unauthorized and return
    end

    unless user.active
      render json: { error: 'Tu cuenta ha sido desactivada. Contacta al administrador.' }, status: :forbidden and return
    end

    # Rebuild params in the shape Devise::Api expects (token[email], token[password])
    params[:token] = creds
    super
  end

  private

  def extracted_sign_in_params
    # Accept both nested token and flat params
    raw = params[:token].presence || params
    raw.permit(:email, :password)
  end

  def sign_up_params
    params.permit(:username, *resource_class.authentication_keys,
                  *::Devise::ParameterSanitizer::DEFAULT_PERMITTED_ATTRIBUTES[:sign_up]).to_h
  end
end
