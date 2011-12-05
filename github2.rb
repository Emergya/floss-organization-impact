#!/usr/bin/env ruby

# Scripts for getting some stats from GitHub
#
# This software is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this package; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Copyright:: Copyright (c) 2011, Emergya
# Authors:: Juanje Ojeda (mailto:jojeda@emergya.es)

require 'open-uri'
require 'json'
require 'mash'
require 'date'

class Organization < Mash
  BASE_URL = "http://github.com/api/v2/json"
  attr_reader :name

  def initialize(org)
    if org.class == String
      @name = org
      url = BASE_URL + "/organizations/#{@name}"
      org_hash = JSON.parse(open(url).read)["organization"]
      Organization.new(org_hash)
    else
      @name = org["name"]
    end
  end

  # Fetches the public_members for a given organization.
  def members
    url = BASE_URL + "/organizations/#{@name}/public_members"
    begin
      opened_url = open(url)
    rescue
      []
    else
      JSON.parse(open(url).read)["users"].collect do |user|
        User.new(user)
      end
    end
  end

  # Fetches the public_repository for a given organization.
  def repositories
    url = BASE_URL + "/organizations/#{@name}/public_repositories"
    JSON.parse(open(url).read)["repositories"].collect do |repo|
      Repository.new(repo)
    end
  end

end


class User < Mash
end

class Repository < Mash
end

org = Organization.new "Emergya"

repos = org.repositories
members = org.members

headers = 'Nombre;Descripcion;Fecha de creacion;Tecnologia;Participantes;Commits' 
puts headers
entries = repos.collect do |repo|
  #puts "\nRepo: #{repo.name}"
  url = "http://github.com/api/v2/json" + "/repos/show/Emergya/#{repo.name}/contributors"
  contribs = JSON.parse(open(url).read)["contributors"]
  commiters = contribs.collect { |contrib|
    if members.any? {|m| m.login == contrib["login"]}
      #puts "Contributor: #{contrib['login']}\tCommits: #{contrib['contributions']}"
      contrib['login']
    end
  }.join(',')
  puts "#{repo.name};#{repo.description};#{repo.created_at};#{repo.language};#{commiters};#{repo.size}"
end

