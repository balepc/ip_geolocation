require 'open-uri'
require 'timeout'
require 'xml'

class IpGeolocation < ActiveRecord::Base

  class UnknownIpGeolocation
    define_method(:city) { "Unknown" }
    define_method(:country) { "Unknown" }
    define_method(:longitude) { "0" }
    define_method(:latitude) { "0" }
  end

  HOSTIP_DEFINED = false # Change it to true to use hostapi.com for retrival

  TIMEOUT = 20
  UNKNOWN = UnknownIpGeolocation.new
  IP_REGEXP = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/

  validates_presence_of :ip_address
  validates_uniqueness_of :ip_address
  validates_format_of :ip_address, :with => IP_REGEXP

  before_create :retrieve_geo

  def self.get(ip_address)
    return UNKNOWN unless valid_ip?(ip_address)
    IpGeolocation.find_by_ip_address(ip_address) || 
      IpGeolocation.create(:ip_address=>ip_address)
  end

  def display
    "#{country}, #{city}"
  end

  private
  def self.valid_ip?(ip_address)
    (ip_address =~ IP_REGEXP) and (ip_address != '127.0.0.1')
  end
  
  def retrieve_geo
    resp = download(request_url)
    if HOSTIP_DEFINED
      attr = parse_string(resp)
    else
      attr= parse_xml(resp)
    end
    self.country, self.city, self.latitude, self.longitude = attr[0], attr[1], attr[2], attr[3]
  end

  def download(url)
    Timeout::timeout(TIMEOUT) do
      open(url).read.to_s
    end
  end
  def request_url
    if HOSTIP_DEFINED
      "http://api.hostip.info/get_html.php?ip=#{ip_address}&position=true"
    else
      "http://ipinfodb.com/ip_query.php?ip=#{ip_address}"
    end
  end

  def parse_xml(xml)
    doc = XML::Document.string(xml)
    status = doc.find('//Response/Status').first.content
    raise unless status == 'OK'
    return doc.find('//Response/CountryName').first.content,
      doc.find('//Response/RegionName').first.content,
      doc.find('//Response/Latitude').first.content,
      doc.find('//Response/Longitude').first.content
  rescue
    return "Unknown", "Unknown", '0', '0'
  end

  def parse_string(r)
    return parse(r, /Country: ([a-zA-Z() ]+)/),
      parse(r,/City: ([a-zA-Z(), ]+)/),
      parse(r,/Latitude: ([0-9.-]+)/, '0'),
      parse(r,/Longitude: ([0-9.-]+)/, '0')
  end

  def parse(r, regexp, default='Unknown')
    match = r.match(regexp)
    return match[1] if match
    return default
  end

end