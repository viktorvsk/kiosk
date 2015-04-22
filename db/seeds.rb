admin = User.create!( name: 'Admin', email: 'admin@kiosk.evotex.kh.ua', password: '0939004419', phone: '+380931234568' )
admin.promote_to :admin
