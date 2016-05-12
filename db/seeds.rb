unless Role.exists?
  ['customer', 'admin'].each do |role|
    Role.find_or_create_by({name: role})
  end
end

unless OrderStatus.exists?
  ['Cancelled', 'Paid', 'Delivered'].each do |status|
    OrderStatus.create(description: status)
  end

  OrderStatus.find_by(description: 'Paid').make_default!
end


