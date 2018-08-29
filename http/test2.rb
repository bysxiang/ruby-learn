require "net/http"

url = "https://p0.meituan.net/dealwatera/44dedb51c314b9414e55a4d045e3b6ed133050.jpg%40640w_1024h_1e_1l%7Cwatermark%3D1%26%26r%3D1%26p%3D9%26x%3D2%26y%3D2%26relative%3D1%26o%3D20";
uri = URI(url)
http = Net::HTTP.new(uri.host, uri.port)
if uri.scheme == "https"
  http.use_ssl = true
  #http.verify_mode = OpenSSL::SSL::VERIFY_PEER
end
response = http.get(uri.request_uri)

puts "输出port, #{uri.port}"
p response
#p response.body