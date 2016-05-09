module Pagination
  extend ActiveSupport::Concern

  def paginate(model, params)
    paginated_model = if params[:page] && params[:per_page]
      model.page(params[:page]).per(params[:per_page])
    elsif params[:page] && !params[:per_page]
      model.page(params[:page])
    else
      model.page(1)
    end

    {
      collection: paginated_model,
      meta: pagination_meta(paginated_model, model)
    }
  end

  def pagination_meta(paginated_model, model)
    {
      page_count: page_count(paginated_model),
      current_page: current_page(paginated_model),
      record_count: record_count(model)
    }
  end

  private

  def page_count(paginated_model)
    paginated_model.total_pages
  end

  def current_page(paginated_model)
    paginated_model.current_page
  end

  def record_count(model)
    model.count
  end
end
