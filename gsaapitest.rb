#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'
require 'builder'

class Gsaapitest
  def initialize
    @url = URI.parse('https://134.68.220.50:8443/accounts/ClientLogin')
  end
  
  def run
    #get our auth token
    get_auth_token(@url)
    
    
    # get the config export xml
  end
  
  
  
  def get_license
    uri = "https://134.68.220.50:8443/feeds/info/licenseInfo"
    
    headers = {}
    headers["Authorization"] = "GoogleLogin auth=#{@token}"
    
    license = get_feed(uri, headers)
    
    return license
    
  end
  
  
  def get_DNI
    url = URI.parse("http://134.68.220.50:8000/feeds/config/crawlURLs")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    
    headers = {
      'Content-type' => 'application/atom+xml',
      'Authorization' => "GoogleLogin auth=#{@token}"
    }
    
    
    
    builder = Builder::XmlMarkup.new({:indent=>2})
    
    builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    
    xml = builder.entry("xmlns" => "http://www.w3.org/2005/Atom", "xmlns:gsa" => "http://schemas.google.com/gsa/2007"){
      builder.id("http://gsa:8000/feeds/config/crawlURLs")
      builder.gsa(:content, "name" => "doNotCrawlURLs")
    }
    
    
    response = http.get(url.path, headers)
    
    puts response.inspect
    
    # Sample request for posting and update
    # <?xml version='1.0' encoding='UTF-8'?>
    # <entry xmlns='http://www.w3.org/2005/Atom' xmlns:gsa='http://schemas.google.com/gsa/2007'>
    #   <id>http://ent1:8000/feeds/config/crawlURLs</id>
    #   <gsa:content name='crawlURLs'>http://yourdomain.com/</gsa:content>
    #   <gsa:content name='startURLs'>http://yourdomain.com/</gsa:content>
    #   <gsa:content name='doNotCrawlURLs'>http://yourdomain.com/not_allow</gsa:content>
    # </entry>
  end

private
  def get_auth_token(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    data = '&Email=' + URI.escape("davpoind", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    data += '&Passwd=' + URI.escape("4xr9q30vOcAFGyR", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    headers = {'Content-Type' => 'application/x-www-form-urlencoded'}

    response, data = http.post(url.path, data, headers)

    case response
        when Net::HTTPSuccess
            then
            # get the auth token from the response
            @token = response.body.split("\n").last.split("=").last
            return @token
        else
          response.error!
          abort("Bad response from GSA!")
        end
  end
  
  def get_feed(uri, headers=nil)
    uri = URI.parse(uri)
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    return http.get(uri.path, headers)
    
  end
end
gsaapitest = Gsaapitest.new.run






    
# Get the DNI list from the GSA using our new auth token



# builder = Builder::XmlMarkup.new({:indent=>2})
# 
# builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
# 
# xml = builder.entry("xmlns" => "http://www.w3.org/2005/Atom", "xmlns:gsa" => "http://schemas.google.com/gsa/2007"){
#   builder.id("http://ent1:8000/feeds/config/crawlURLs")
#   builder.gsa(:content, "http://134.68.220.50:8000/not_allow", "name" => "doNotCrawlURLs")
# }

