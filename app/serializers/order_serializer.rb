class OrderSerializer < ActiveModel::Serializer
  attributes :id, :total, :order_details, :order_status, :customer_id
  self.root = false

  def order_details
    prods = object.products.map { |p| OrderProductSerializer.new(p).attributes }
    placms = object.placements.map { |pl| PlacementSerializer.new(pl).attributes }
    (prods + placms).group_by{ |h| h[:product_id] }.map{ |k,v| v.reduce(:merge) }
  end
end
