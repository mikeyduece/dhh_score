require 'faraday'
require 'json'

class DhhScore
  attr_reader :response

  def initialize
    @response = Faraday.get('https://api.github.com/users/dhh/events/public')
  end

  def parse_json
    JSON.parse(response.body, symbolize_names: true)
  end

  def score_type
    score = Hash.new(0)
    parse_json.each do |commit|
      case commit[:type]
      when 'IssuesEvent' then score['IssuesEvent'] += 7
      when 'IssueCommentEvent' then score['IssueCommentEvent'] += 6
      when 'PushEvent' then score['PushEvent'] += 5
      when 'PullRequestReviewCommentEvent' then score['PullRequestReviewCommentEvent'] += 4
      when 'WatchEvent' then score['WatchEvent'] += 3
      when 'CreateEvent' then score['CreateEvent'] += 2
      else
        score[commit[:type]] += 1
      end
    end
    score
  end

  def calculate_github_score
    score_type.values.sum
  end
end

dhh = DhhScore.new
score = dhh.calculate_github_score
puts "DHH's github score is #{score}"

