# intial implementation from https://discuss.rubyonrails.org/t/a-simple-pagination-concern/77041
# credit to Jonathan Allard (joallard)
# with modification
module Pagination
  extend ActiveSupport::Concern

  def default_per_page
    25
  end

  def page_no
    params[:page]&.to_i || 1
  end

  def page_size
    (params[:page_size]&.to_i || default_per_page).clamp(1,500)
  end

  def paginate_offset
    (page_no-1)*page_size
  end

  def paginate
    ->(it){ it.limit(page_size).offset(paginate_offset) }
  end
end
