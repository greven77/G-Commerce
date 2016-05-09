module Pagination
  extend ActiveSupport::Concern

  def paginate(model, params)
    if params[:page] && params[:per_page]
      model.page(params[:page]).per(params[:per_page])
    elsif params[:page] && !params[:per_page]
      model.page(params[:page])
    else
      model.page(1)
    end
  end

  def pagination_meta(model, params)
    {
      page_count: page_count(model, params),
      current_page: current_page(model, params),
      record_count: record_count(model)
    }
  end

  private

  def page_count(model, params)
    paginate(model, params).total_pages
  end

  def current_page(model, params)
    paginate(model, params).current_page
  end

  def record_count(model)
    model.count
  end
end
