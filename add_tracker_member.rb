#!/usr/bin/env ruby

require "pry"
require "dotenv"
require "pivotal-tracker"
require "octokit"
require "json"
require "yaml"

Dotenv.load

def add_user_to_github
  puts "adding user to github team"
  github_client = Octokit::Client.new(
    :login => ENV["GITHUB_LOGIN"], 
    :password => ENV["GITHUB_PASSWORD"])
  if github_client.add_team_member(
    ENV["GITHUB_TEAM_ID"], 
    @user["github_login"])
    puts "success!"
  end
end

def add_user_to_tracker
  PivotalTracker::Client.token = ENV["PIVOTAL_TOKEN"]
  PivotalTracker::Client.use_ssl = ENV["PIVOTAL_PROJECT_USE_SSL"]

  pivotal_project = PivotalTracker::Project.find(ENV["PIVOTAL_PROJECT_ID"])
  pivotal_project.memberships.add!(
    role:     @user["role"], 
    name:     @user["name"],  
    email:    @user["email"],
    initials: @user["initials"])
end

@user = YAML.load_file("user.yaml")["user"]
add_user_to_tracker
add_user_to_github
