#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'tmail'
require 'zlib'

lists = ['orca-list']
         #'gnome-accessibility-devel']
base_url = 'http://mail.gnome.org/archives/'

dataset = open('mails_dataset.csv', 'w')
dataset.write "Date,From,Subject\n"

lists.each do |list|
  puts "List: #{list}"
  url = base_url + list
  doc = Nokogiri::HTML(open url)
  files = doc.xpath('//tr/td/a').collect do |row|
    href = row.attribute('href').value
    href if href.end_with? "txt.gz"
  end
  files.reverse.each do |file|
    next if not file
    file_url = url + "/" + file
    local_file = file.chomp('.gz')
    File.open(local_file, 'w') do |f|
      data = open(file_url)
      f.write Zlib::GzipReader.new(StringIO.new(data.read)).read
      data.close
    end
    puts "Remote: #{file_url}\tLocal file: #{local_file}"
    mailbox = TMail::UNIXMbox.new(local_file, nil, true)

    emails = []
    mailbox.each_port { |m|
        mail = TMail::Mail.new(m)
        puts mail.subject
        emails << mail
        }
    File.delete(local_file)

    mails = emails.collect do |mail|
        dataset.write "#{mail.date},\"#{mail.from}\",\"#{mail.subject}\"\n"
        { :date => mail.date,
          :from => mail.from,
          :subject => mail.subject }
    end
  end
end

dataset.close
