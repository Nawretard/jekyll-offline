#!/usr/bin/env ruby

require 'erb'
require 'fileutils'
require 'yaml'

require_relative 'html_to_offline.rb'

def copy_local_site(source, target)
  project_name = File.basename(File.dirname(source)).split('\\')[-1] + "_offline" # main folder in target
   
  main_folder_path = File.join(target, project_name)

  # Clear before copy
  FileUtils.rm_rf(main_folder_path) # Remove the main folder if it already exists
  FileUtils.mkdir_p(main_folder_path)

  # Copy all contents of the source directory to the main folder path
  Dir.glob(File.join(source, '*')).each do |item|
    FileUtils.cp_r(item, main_folder_path)
  end  
  main_folder_path
end

def create_offline_site(main_folder_path, site_url)
  pages = Dir.glob(File.join(main_folder_path, "**", "*.html"))
  pages.each do |page_path|
    page_output = convert_to_offline(page_path, main_folder_path, site_url)
    File.open(page_path, "w") {|f| f << page_output }
  end
end

@config = YAML::load(File.read("config.yml"))
custom_config = ARGV[0]
if custom_config
  @config = YAML::load(File.read(custom_config))
end

source = File.absolute_path(@config[:source].gsub(/^~/, Dir.home))
target = File.absolute_path(@config[:target].gsub(/^~/, Dir.home))
site_url = @config[:site_url]

main_folder_path = copy_local_site(source, target)
create_offline_site(main_folder_path, site_url)
