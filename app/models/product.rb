class Product < ActiveRecord::Base
  attr_accessible :name,
                  :description,
                  :price,
                  :quantity,
                  :featured,
                  :image,
                  :active,
                  :categories_list,
                  :store_id,
                  :photo_url

  default_scope { where(store_id: Store.current_id)  }

  validates :name,        presence: true
  validates :description, presence: true

  validates :price,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :quantity,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :featured,    inclusion: { in: [false, true] }
  validates :active,      inclusion: { in: [false, true] }

  has_many  :product_categories
  has_many  :categories, through: :product_categories

  has_many  :cart_products,      dependent: :destroy
  has_many  :carts,              through:   :cart_products

  has_many  :order_products,     dependent: :destroy
  has_many  :orders,             through:   :order_products

  has_attached_file :image,
                    styles: { medium: "454x627>", thumb: "182x304>" },
                    default_url: "http://placekitten.com/600/600"

  #scope :active, where(active: true)

  def categories_list
    categories.join(", ")
  end

  def categories_list=(cats_string)
    cat_names = cats_string.split(",").collect{|s| s.strip.downcase}.uniq
    new_or_found_cats = cat_names.map do  |name| 
      Category.find_or_create_by_name_and_store_id(name, self.store_id)
    end
    self.categories = new_or_found_cats
  end
end
