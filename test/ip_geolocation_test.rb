require 'test/helper'

class IpGeolocationTest < Test::Unit::TestCase

  class Readable
    define_method(:read) {|smth| smth.to_s }
  end
  
  context "Validations" do
    should "return UNKNOWN if no ip address" do
      assert_equal IpGeolocation::UNKNOWN, IpGeolocation.get(nil)
    end
    should "return UNKNOWN if ip address is not valid" do
      assert_equal IpGeolocation::UNKNOWN, IpGeolocation.get('266.1.1.1')
      assert_equal IpGeolocation::UNKNOWN, IpGeolocation.get('266')
      assert_equal IpGeolocation::UNKNOWN, IpGeolocation.get('1.1.1.1.1')
    end
  end
  
  context "Process" do
    setup do
      IpGeolocation.destroy_all
      IP = '10.0.0.1'
    end

    should "return existing object" do
      IpGeolocation.any_instance.expects(:retrieve_geo)
      IpGeolocation.create(:ip_address=>IP, :country=>'Latvia', :city=>'Riga')
      assert_equal 'Riga', IpGeolocation.get(IP).city
    end
    should "retrieve object from sources, if object doesn't exists" do
      IpGeolocation.expects(:create)
      IpGeolocation.get(IP)
    end
  end

  context "Different sources" do
    setup do
      IpGeolocation.destroy_all
      IP = '10.0.0.1'
    end

    should "return hostip.com url if HOSTIP_DEFINED" do
      IpGeolocation::HOSTIP_DEFINED = true
      IpGeolocation.any_instance.expects(:download).with("http://api.hostip.info/get_html.php?ip=#{IP}&position=true").returns('')
      assert_equal "Unknown", IpGeolocation.get(IP).country
    end
    should "return ipinfodb.com url if !NO! HOSTIP_DEFINED" do
      IpGeolocation::HOSTIP_DEFINED = false
      IpGeolocation.any_instance.expects(:download).with("http://ipinfodb.com/ip_query.php?ip=#{IP}").returns('')
      assert_equal "Unknown", IpGeolocation.get(IP).country
    end
  end

  context "Scenarios" do
    setup do
      IpGeolocation.destroy_all
      IP = '10.0.0.1'
    end
    should "retrieve and parse data from ipinfodb.com" do
      IpGeolocation::HOSTIP_DEFINED = false
      IpGeolocation.any_instance.expects(:download).returns('<?xml version="1.0" encoding="UTF-8"?>
<Response>
	<Ip>212.142.79.180</Ip>
	<Status>OK</Status>
	<CountryCode>LV</CountryCode>
	<CountryName>Latvia</CountryName>
	<RegionCode>25</RegionCode>

	<RegionName>Riga</RegionName>
	<City>Riga</City>
	<ZipPostalCode></ZipPostalCode>
	<Latitude>56.95</Latitude>
	<Longitude>24.1</Longitude>
	<Gmtoffset>2.0</Gmtoffset>

	<Dstoffset>3.0</Dstoffset>
</Response>
        ')
      geo = IpGeolocation.get('12.215.42.19')
      assert_equal 'Latvia', geo.country
      assert_equal 'Riga', geo.city
      assert_equal '56.95', geo.latitude
      assert_equal '24.1', geo.longitude
    end
    should "return UNKNOWN if couldn recongize" do
      IpGeolocation::HOSTIP_DEFINED = false
      IpGeolocation.any_instance.expects(:download).returns('<?xml version="1.0" encoding="UTF-8"?>
<Response>
<Ip>212.142.79.277</Ip>
<Status>IP NOT FOUND IN DATABASE, SORRY!</Status>
<CountryCode/>
<CountryName/>
<RegionCode/>
<RegionName/>
<City/>
<ZipPostalCode/>
<Latitude/>
<Longitude/>
<Gmtoffset/>
<Dstoffset/>
</Response>
        ')
      geo = IpGeolocation.get('12.215.42.19')
      assert_equal 'Unknown', geo.country
    end

    should "retrieve and parse data from api.hostip.info" do
      IpGeolocation::HOSTIP_DEFINED = true
      IpGeolocation.any_instance.expects(:download).returns('Country: UNITED STATES (US)
City: Sugar Grove, IL
Latitude: 41.7696
Longitude: -88.4588')
      geo = IpGeolocation.get('12.215.42.19')
      assert_equal 'UNITED STATES (US)', geo.country
      assert_equal 'Sugar Grove, IL', geo.city
      assert_equal '41.7696', geo.latitude
      assert_equal '-88.4588', geo.longitude
    end
  end
  
end
