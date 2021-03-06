module Calypso

  module GithubClient

    module IssuesAPI

      def issues(labels: nil, state: nil, filter: nil, sort: nil, direction: nil, since: nil, pages: 10)
        query = {}
        query['labels'] = labels unless labels.nil?
        query['state'] = state unless state.nil?
        query['sort'] = sort unless sort.nil?
        query['direction'] = direction unless direction.nil?
        query['since'] = since unless since.nil?
        query['filter'] = filter unless filter.nil?
        fetch(issues_url, query: query, pages: pages).select { |issue| issue['pull_request'].nil? }
      end

      def group_issues_by_labels(issues)
        labels_issues = {}
        issues.each do |issue|
          issue_labels = issue['labels']

          if issue_labels.empty?
            label_name = 'unknown'
            labels_issues[label_name] ||= []
            labels_issues[label_name] << issue
            next
          end

          issue_labels.each do |label|
            label_name = label['name']
            labels_issues[label_name] ||= []
            labels_issues[label_name] << issue
          end
        end
        labels_issues
      end

      private

      def issues_url
        repos_url('issues')
      end

    end

  end

end
