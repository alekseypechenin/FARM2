class FieldsController < ApplicationController

  before_filter :login_required

  ############ Flex actions ##############

  # GET /fields
  # GET /fields.xml
  def indextoclient
    @user = current_user
    @fields = @user.fields.all
    render :xml => @fields
  end

  # POST /fields
  # POST /fields/.xml/createtoserver params
  def createtoserver
    @user = current_user
    @field = @user.fields.new(ftype: params[:ftype],
                       fstate: 1,
                       x: params[:x],
                       y: params[:y])
    if  @field.save
      render :xml => @field
    else
      render :xml => "error"
    end
  end

   # POST /fields
  # POST /fields/growallfields

  def growallfields
    @user = current_user
    @fields = @user.fields.all
    @fields.each { |field|
        if (field.fstate != 5) then
          field.fstate = field.fstate + 1
          field.update_attribute(:fstate, field.fstate)
        end
      }
    render :xml => @fields
  end

  # POST /fields
  # POST /fields.xml
  def takefield
    @user = current_user
    @field = @user.fields.find(params[:id])

    if (@field.nil?) then
      render :xml => "error"
    else
       if @field.fstate == 5 then
     @field.destroy
      end
      @fields = @user.fields.all
      render :xml => @fields
    end
  end

  # PUT /fields/1
  # PUT /fields/update :params
  def update
    @user = current_user
    @field = @user.fields.find(params[:id])
    if @field.update_attributes(x: params[:x],y: params[:y])
       render :xml => @field
     else
       render :xml => "error"
    end
  end

  ############ Flex actions ##############

end