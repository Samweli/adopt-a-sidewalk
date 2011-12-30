class MapObjectsController < ApplicationController
  respond_to :html, :json
  
  layout 'info_window'

  def index
  end

  def create
    find_object
    
    if user_signed_in?
      if @map_object.try :belongs_to_me?
        puts 'already claimed!'
        # trying to adopt an object that I already adopted
      else
        @map_object = MapObject.new do |o|
          if sidewalk = Sidewalk.find_by_gid(@gid)
            loc = Address.geocode("#{sidewalk.address}, Chicago, IL")
            o.lat, o.lng = loc[0], loc[1]
            o.object_type = MapObject::OBJECT_TYPES[:sidewalk]
            o.source_type = MapObject::SOURCE_TYPES[:user]
            o.source_id = current_user.id
            o.gid = params[:id]
            o.claimed = true
          end
        end
        
        if @map_object.save
          respond_with @map_object
        else
          render(:json => {"errors" => @map_object.errors}, :status => 500)
        end
      end
    else
      render 'users/new'
    end
  end

  def show
    find_object
    respond_with @map_object
    #if @map_object.adopted?
    #  if user_signed_in? && current_user.id == @map_object.user_id
    #    render("users/thank_you")
    #  else
    #    render("users/profile")
    #  end
    #else
    #  if user_signed_in?
    #    render("map_objects/adopt")
    #  else
    #    render("sessions/new")
    #  end
    #end

  end

  def update
    @map_object = MapObject.find(params[:id])
    if @map_object.update_attributes(params[:thing])
      respond_with @map_object
    else
      render(:json => {"errors" => @map_object.errors}, :status => 500)
    end
  end
  
  private
  
  def find_object
    @gid = params[:id]
    @map_object = MapObject.find_by_gid(@gid)
    puts ">>> Found adopted sidewalk [#{@map_object.gid}]" if @map_object
  end
end
