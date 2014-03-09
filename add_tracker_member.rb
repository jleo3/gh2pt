#!/usr/bin/env ruby

require "pry"
require "dotenv"
require "pivotal-tracker"
require "json"
require "yaml"

Dotenv.load
user = YAML.load_file("user.yaml")["user"]

PivotalTracker::Client.token = ENV["PIVOTAL_TOKEN"]
PivotalTracker::Client.use_ssl = ENV["PIVOTAL_PROJECT_USE_SSL"]

pivotal_project = PivotalTracker::Project.find(ENV["PIVOTAL_PROJECT_ID"])


pivotal_project.memberships.add!(
  role:     user["role"], 
  name:     user["name"],  
  email:    user["email"],
  initials: user["initials"])
