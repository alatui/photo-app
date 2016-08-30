class RegistrationsController < Devise::RegistrationsController



  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.class.transaction do
      resource.save
      yield resource if block_given?
      if resource.persisted?
        @payment = Payment.new(email: resource.email, token: params[:payment]['token'], user: resource)
        flash.now[:error] = 'Please check registration errors' unless @payment.valid?
        begin
          @payment.process_payment
          @payment.save
        rescue Exception => e
          flash.now[:error] = e.message
          puts 'Payment failed'
          render :new and return
        end
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
  end


=begin
  def create
    super do |resource|
      if resource.persisted?
        @payment = Payment.new(email: resource.email)
        if @payment.valid?
          puts 'ok------------------------'
        else
          resource.destroy
          return
        end
      end
    end
  end
=end


  #protected
    #def configure_permitted_parameters
      #devise_parameter_sanitizer.permit(:sign_up, keys: [:payment])
    #end

end