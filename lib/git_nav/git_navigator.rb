module GitNav
  class GitNavigator
    def initialize(repo=nil)
      repo ||= Dir.pwd
      raise GitError.new("Not a git repo") unless is_git_repo?(repo)
      Dir.chdir repo
    end

    def commits
      reflog = GitWrapper.reflog.split("\n").map! {|entry| entry.split(": ")}
      commits = reflog.select {|entry| entry[1].scan("commit").count > 0}
      commits.map!{|commit| [commit.first.split.first, commit.last] }
    end

    def current_head
      commits.first
    end

    private

    def is_git_repo?(repo)
      File.exist?(File.join(repo, ".git"))
    end
  end
end

