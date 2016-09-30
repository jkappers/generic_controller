module GenericActions
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, only: %i(show update destroy)
  end

  def index
    @resource = apply_filters(filter_params).all
    render json: @resource, include: params[:include]
  end

  def show
    render json: @resource
  end

  def find
    @resource = apply_filters(filter_params).first

    if @resource
      render json: @resource
    else
      render status: :not_found
    end
  end

  def create
    @resource = resource_class.new resource_params

    if @resource.save
      render json: @resource, status: :created
    else
      render json: { errors: @resource.errors }, status: :unprocessable_entity
    end
  end

  def update
    @resource.assign_attributes resource_params

    if @resource.save
      render json: @resource
    else
      render json: { errors: @resource.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy
    head :no_content
  end

  private

  def set_resource
    @resource = resource_class.find params[:id]
  end

  def resource_params
    permitted = resource_class.column_names.map { |k| k.to_sym }
      .except(:created_at, :updated_at)

    params
      .require(controler_name.singularize.to_sym)
      .permit(*permitted)
  end

  def resource_class
    @resource_class ||= controller_path
      .singularize
      .camelize
      .constantize
  end

  def apply_filters(options = {})
    options.reduce(resource_class) do |chain, (k,v)|
      self.class.filters[k].call(chain, v)
    end
  end

  def filter_params
    params[:filter].try(:permit, *self.class.filters.keys).to_h
  end

  class_methods do
    attr_reader :filters

    def filter(key, function = nil)
      @filters ||= HashWithIndifferentAccess.new
      @filters[key] = function || -> (chain, value) { chain.where key => value }
    end
  end
end
