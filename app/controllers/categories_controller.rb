class CategoriesController < GroupDataController

  respond_to :html, :js
  
  def index
    @categories = current_group.categories.order("name").page(params[:page])
    
    collection_authorize! :read, @categories
    
    respond_with(@categories) do |format|
      format.html
      format.js
    end
  end

  def show
    @category = current_group.categories.find(params[:id])

    is_authorized? :read, @category
    
    @properties = current_group.properties.where(:category_id => @category.id).count(:id)

    respond_with(@category) do |format|
      format.html
      format.js
    end
  end

  def new
    @depth = params[:depth].to_i

    @category = Category.new do |c|
      c.group = current_group
      c.creator = current_user
      c.depth = @depth
    end

    is_authorized? :create, @category
  end

  def edit
    @category = current_group.categories.find(params[:id])

    is_authorized? :update, @category

    @depth = @category.depth
  end

  def create
    if params[:category].nil?
      render :action => "new" and return
    end

    @depth = params[:category].delete(:depth).to_i

    @category = Category.new(category_params) do |category|
      category.group = current_group
      category.creator = current_user
      category.depth = @depth
    end
    is_authorized? :create, @category

    if @category.save
      redirect_to([current_group, @category],
                  :notice => (current_group.category_name + ' was successfully created.'))
    else
      render :action => "new"
    end
  end

  def update
    if params[:category].nil?
      render :action => "edit" and return
    end

    @category = current_group.categories.find(params[:id])
    
    is_authorized? :update, @category

    @depth = params.try(:category).try(:depth).nil? ? @category.depth : params[:category][:depth]&.to_i

    if @category.update_attributes(category_params)
      redirect_to([current_group, @category],
                  :notice => (current_group.category_name + ' was successfully updated.'))
    else
      render :action => "edit"
    end
  end

  def destroy
    @category = current_group.categories.find(params[:id])
    is_authorized? :destroy, @category

    @category.destroy

    redirect_to(group_categories_url(current_group))
  end
  
  def category_params
    params.require(:category).permit!
  end
end
