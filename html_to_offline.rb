# Converts a html file to a offline html file
# Input : 
# - page_path: html file path
# - main_folder_path: (kinda useless, but now we have the page relative path)
# - site_url: remove this from every link
# Output :
# - page_content, hopefully our html file adapted for local use
require 'pathname'

def convert_to_offline(page_path, main_folder_path, site_url) # Flemme d'améliorer la signature, déso
  page_relative_path = page_path.gsub(/^#{main_folder_path}/, "") # Path relative to the working directory

  page_content = File.read(page_path)

  page_content = page_content.gsub(/(href|src)=["'](.*?)["']/) do |link|
    href = $1
    address = $2

    unless is_custom_filter?() || (is_url?(address) && !address.start_with?(site_url))
      # add index.html to folder links that end with "/"
      address += "index.html" if address.end_with?("/")

      # add /index.html to folder links that end like "/something" with no extension
      address += "/index.html" unless has_extension?(address)

      # remove the site_url from paths
      address.sub!(/^#{Regexp.escape(site_url)}/, "")

      # remove the multiple "/"
      address.gsub!(/\/+/, '/')

      # create the relative path from the page to the link address
      address = construct_relative_path(page_relative_path, "/") + address

      # remove the first "/"
      address = address.sub(/^\//, "");
    end
    href + "=" + "'#{address}'"
  end
  page_content
end

def is_custom_filter?()
  @config[:custom_filter] && href.match(/#{@config[:custom_filter]}/)
end

def is_url?(address)
  # Check if the address starts with common web references
  return true if address.match?(/\A(http|https|ftp|mailto)/)
  false
end


def has_extension?(file_path)
  !File.extname(file_path).empty?
end

def construct_relative_path(from_address, to_address)
  from_path = Pathname.new(from_address)
  to_path = Pathname.new(to_address)

  relative_path = to_path.relative_path_from(from_path.dirname).to_s

  # Adjust the relative path to include "../" if necessary
  relative_path.empty? ? '.' : relative_path
end