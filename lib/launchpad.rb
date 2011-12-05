require 'open-uri'
require 'json'
require 'mongo'
load File.dirname(__FILE__) + '/common.rb'

module Launchpad
  BASE_URL = "https://api.launchpad.net/devel"


  def self.user_repositories user
    include Common
    url = BASE_URL + "/~#{user}?ws.op=getBranches"
    begin
      opened_url = open(url)
    rescue
      []
    else
      JSON.parse(opened_url.read)["entries"].collect { |repo|
        if repo["branch_type"] == "Hosted"
          Repo.new(:name => repo["unique_name"],
                   :type => "bazaar",
                   :num_of_commits => repo["revision_count"]
                  )
        end
      }.compact
    end
  end

  def self.organization_members org
    include Common
    url = BASE_URL + "/~#{org}/members"
    begin
      opened_url = open(url)
    rescue
      []
    else
      JSON.parse(opened_url.read)["entries"].collect { |user|
        repos = user_repositories(user["name"])
        puts "User: #{user["name"]} \n#{repos.join("\n")}"
        User.new(:username => user["name"],
                 :fullname => user["display_name"],
                 :repos => repos
                )
      }.compact
    end
  end

  def self.get_organization org
    #Organization.new(:name => org,
    #                 :users => organization_members(org)
    #                )
    members = organization_members(org)
    db = Mongo::Connection.new('staff.mongohq.com', 10083).db('datasets')
    if db.authenticate('admin', 'osladmin2003')
      coll = db.collection('launchpad')
      members.each do |member|
        coll.insert(member)
      end
    else
      puts "I couldn't connect"
    end

  end

end
