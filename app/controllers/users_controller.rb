class UsersController < Devise::RegistrationsController
  layout 'info_window'

  def new
    respond_with (@user = User.new)
  end

  def edit
    render :edit, :layout => "info_window"
  end

  def update
    if resource.update_with_password(params[resource_name])
      sign_in(resource_name, resource, :bypass => true)
      flash[:notice] = "Profile updated!"
      redirect_to(:controller => "info_window", :action => "index", :map_object_id => params[:map_object_id])
    else
      clean_up_passwords(resource)
      render(:json => {"errors" => resource.errors}, :status => 500)
    end
  end

  def create
    if verify_recaptcha
      build_resource
      if resource.save
        sign_in resource
        #puts "created: #{resource.class} #{resource.inspect}"
        render :inline => "You have been registered!" and return
      end
    end

    clean_up_passwords(resource)
    render(:json => {"errors" => resource.errors,
                    :html => render_to_string(:template => 'users/new.html.haml')},
                    :status => 500)
  end
end
