module Common

require 'mongo_mapper'

  class Repo
    include MongoMapper::Document
    
    key :name, String
    key :type, String
    key :commits, Array # [commit.id, commit.id...]
    key :bugs, Array # [Bug.id, Bug.id...]
  end

  class Commit
    include MongoMapper::Document
    
    key :id, Integer
    key :author, String # User.id
    key :commited_at, Time
  end

  class Bug
    include MongoMapper::Document
    
    key :id, Integer
    key :created_by, String # User.id
    key :assigned_to, String # User.id
    key :reported_at, Time
    key :status, String
  end

  class User
    include MongoMapper::Document
    
    key :id, Integer
    key :username, String
    key :fullname, String
    key :email, String
    key :start_at, Time
    key :active, Boolean
    key :repos, Array # [Repo.id, Repo.id...]
    key :bugs, Array # [Bug.id, Bug.id...]
  end

  class Organization
    include MongoMapper::Document
    
    key :id, Integer
    key :name, String
    key :repos, Array # [Repo.id, Repo.id...]
    key :members, Array # [User.id, User.id...]
  end

end
