#!/usr/bin/env ruby

require "pry"
require "dotenv"
require "octokit"
require "pivotal-tracker"
require "json"

Dotenv.load

GITHUB_ORG = ENV["GITHUB_ORG"]
GITHUB_USER = ENV["GITHUB_USER"]
GITHUB_REPO = ENV["GITHUB_REPO"]
GITHUB_LOGIN = ENV["GITHUB_LOGIN"]
GITHUB_PASSWORD = ENV["GITHUB_PASSWORD"]

PIVOTAL_PROJECT_ID = ENV["PIVOTAL_PROJECT_ID"]
PIVOTAL_PROJECT_USE_SSL = ENV["PIVOTAL_PROJECT_USE_SSL"]
PIVOTAL_TOKEN = ENV["PIVOTAL_TOKEN"]

PivotalTracker::Client.token = PIVOTAL_TOKEN
PivotalTracker::Client.use_ssl = PIVOTAL_PROJECT_USE_SSL

pivotal_project = PivotalTracker::Project.find(PIVOTAL_PROJECT_ID)
github = Octokit::Client.new(:login => GITHUB_LOGIN, :password => GITHUB_PASSWORD)
issues_filter = 'task' # update filter with 'feature', 'task', 'bug'
story_type = 'chore' # 'bug', 'feature', 'chore'
story_current_state = 'unscheduled' 
total_issues = 0
page_issues = 1
issues = github.list_issues(GITHUB_REPO, { :page => page_issues, :labels => issues_filter } )

while issues.count > 0
  
  issues.each do |issue|
    total_issues += 1
    comments = github.issue_comments(GITHUB_REPO, issue.number)
    labels = 'github-import'
    issue.labels.each do |l|
      labels += ",#{l.name}"
    end

    puts "issue #{total_issues}: #{issue.number} #{issue.title}, with #{comments.count} comments"
    story = pivotal_project.stories.create(
              :name => issue.title,
              :description => issue.body,
              :created_at => issue.created_at,
              :labels => labels,
              :story_type => story_type,     
              :current_state => story_current_state)

    story.notes.create(text: "Migrated from #{issue.html_url}")

    comments.each do |comment|
      story.notes.create(
        text: comment.body.gsub(/\r\n\r\n/, "\n\n"),
        author: comment.user.login,
        noted_at: comment.created_at)
    end
  end

  page_issues += 1
  issues = github.list_issues(GITHUB_REPO, { :page => page_issues, :labels => issues_filter } )
end
