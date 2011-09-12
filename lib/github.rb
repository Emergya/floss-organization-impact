require 'open-uri'
require 'json'
load File.dirname(__FILE__) + '/utils.rb'

module Github
  BASE_URL = "http://github.com/api/v2/json"

  include Utils

  class User < Base
    attr_accessor :name, :fullname, :emails, :commits, :owned_repos

    def email
      @emails.first if @emails
    end

    def own_repo?(repo)
      if @owned_repos
        @owned_repos.include? repo
      else
        false
      end
    end
  end

  class Repo < Base
    attr_accessor :name, :owner, :commiters, :commits

    def commits?
      @commits.length
    end
  end

  class Commit < Base
    attr_accessor :id, :author, :repo, :date, :description
  end

  class Organization < Base
    attr_accessor :name, :members, :repos

    def member? user
      if @members
        @members.include? user
      else
        false
      end
    end
  end

  def self.commits_from user, repository
    url = BASE_URL + "/commits/list/#{user}/#{repository}/master"
    begin
      opened_url = open url
    rescue
      []
    else
      JSON.parse(opened_url.read)["commits"].collect do |commit|
        Commit.new(:id => commit["id"],
                   :author => user,
                   :repo => repository,
                   :date => commit["committed_date"],
                   :description => commit["message"]
                  )
      end
    end
  end

  def self.user_repositories user
    url = BASE_URL + "/repos/show/#{user}"
    begin
      opened_url = open(url)
    rescue
      []
    else
      JSON.parse(opened_url.read)["repositories"].collect { |repo|
        if repo["fork"] == false
          Repo.new(:name => repo["name"],
                   :owner => user,
                   :commiters => [user],
                   :commits => commits_from(user, repo["name"])
                        )
        end
      }.compact
    end
  end
end
