class ApplicationController < ActionController::API
  include ActionController::Serialization
#  protect_from_forgery with: :null_session

  private

  def authenticate_user
    user_id = params[:auth_user_id].presence
    @user ||=  user_id && User.find_by_id(user_id)
  end

  def authenticate_user_from_token!
    if authenticate_user && Devise.secure_compare(@user.authentication_token, params[:auth_token])
      @current_user = authenticate_user
    else
      return permission_denied
    end
  end

  def permission_denied
    render json: { error: "Unauthorized"}, status: 401
  end

  def split_base64(uri_str)
    if uri_str.match(%r{^data:(.*?);(.*?),(.*)$})
      uri_attrs = uri_str.split(/[:;,]/)[1..3]
      uri = Hash.new
      uri[:type] = uri_attrs[0]
      uri[:encoder] = uri_attrs[1]
      uri[:data] =  uri_attrs[2]
      uri[:extension] = uri[:type].split('/')[1]
      return uri
    else
      return nil
    end
  end

  def convert_data_uri_to_upload(obj_hash)
    if obj_hash[:image_url].try(:match, %r{^data:(.*?);(.*?),(.*)$})
      image_data = split_base64(obj_hash[:image_url])
      image_data_string = image_data[:data]
      image_data_binary = Base64.decode64(image_data_string)
      temp_img_file = Tempfile.new("")
      temp_img_file.binmode
      temp_img_file << image_data_binary
      temp_img_file.rewind

      img_params = {:filename => "image.#{image_data[:extension]}",
                    :type => image_data[:type], :tempfile => temp_img_file}
      uploaded_file = ActionDispatch::Http::UploadedFile.new(img_params)

      obj_hash[:image] = uploaded_file
      obj_hash.delete(:image_url)
    end
    return obj_hash
  end
end
