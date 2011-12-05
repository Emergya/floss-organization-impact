#!/usr/bin/env ruby

require 'zlib'
require 'tmail'

mails = ''
Zlib::GzipReader.open('2006-March.txt.gz') { |gz| mails = gz.read }
File.open('2006-March.txt', 'w') { |f| f.write mails }

mailbox = TMail::UNIXMbox.new("2006-March.txt", nil, true)

emails = []
mailbox.each_port { |m| emails << TMail::Mail.new(m) }

emails.each {|mail| p mail.subject if mail.body.include? "Gnopernicus" }

mails = emails.collect do |mail|
    { :date => mail.date,
      :from => mail.from,
      :subject => mail.subject }
      puts mail.subject
end

