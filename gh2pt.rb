require "dotenv"
require "rubygems"
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
issues_filter = 'feature' # update filter as appropriate
story_type = 'feature' # 'bug', 'feature', 'chore', 'release'. Omitting makes it a feature.
story_current_state = 'unscheduled' # 'unscheduled', 'started', 'accepted', 'delivered', 'finished', 'unscheduled'.
                                    # 'unstarted' puts it in 'Current' if Commit Mode is on; 'Backlog' if Auto Mode is on.
                                    # Omitting puts it in the Icebox.
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
  end

  page_issues += 1
  issues = github.list_issues(GITHUB_REPO, { :page => page_issues, :labels => issues_filter } )
end
