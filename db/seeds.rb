admin = User.create!( name: 'Admin', email: 'admin@kiosk.evotex.kh.ua', password: '0939004419', phone: '+380931234568' )
admin.promote_to :admin

10.times do |i|
  User.create(name: "Test #{i}", email: "test#{i}@test.ua", password: "00000000", phone: "+38093123456#{i}" )
end

10.times do |i|
  Markup.create(name: "test #{i}", body: 'test')
end
