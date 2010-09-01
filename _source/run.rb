require 'rubygems'
require 'open-uri'
require 'broadway'

site = Broadway.build(:source => "_source/posts", :settings => "_source/_config.yml", :destination => ".")

def error?(response, path, whiny = true)
  if !response.is_a?(Net::HTTPSuccess)
    raise message if whiny
    puts "Error at '#{path}': #{response.to_s}"
    return true
  end
  false
end

paths = ["/", "/tips", "/readme"]

url = URI.parse("http://localhost:4567")
begin
  Net::HTTP.start(url.host, url.port) do |http|
    paths.each do |path|
      response = http.get(path)
      write_to = File.expand_path(File.join(site.setting(:destination), path).squeeze("/"))
      # if the file doesn't exist or is not rendered correctly
      next if error?(response, path, false)
      #FileUtils.mkdir_p(write_to)
      name = "#{write_to}.html"# File.join(write_to, "index.html")
      puts "NAME #{name}"
      File.open(name, "w") { |f| f.write(response.body) }
    end
  end
rescue Exception => e
  puts e.inspect
  raise "Make sure you've started the server, run: 'ruby app.rb'"
end