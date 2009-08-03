ActiveRecord::Schema.define(:version => 0) do
  
  create_table "ip_geolocations", :force => true do |t|
    t.string   "ip_address", :null => false
    t.string   "city"
    t.string   "country"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
end
