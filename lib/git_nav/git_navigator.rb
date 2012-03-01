module GitNav
  class GitNavigator
    attr_reader :commits

    def initialize(repo=nil)
      repo ||= Dir.pwd
      raise GitError.new("Not a git repo") unless is_git_repo?(repo)
      Dir.chdir repo
      get_commits
    end

    def get_commits
      reflog = GitWrapper.reflog.split("\n").map! {|entry| entry.split(": ")}
      @commits = reflog.select {|entry| entry[1].scan("commit").count > 0}
      @commits.map!{|commit| [commit.first.split.first, commit.last] }
    end

    def current_head
      head = GitNav::GitWrapper.head
      return @commits.first if head.scan("ref:").count > 0
      ref = head[0..6]
      @commits.select {|commit| commit.first == ref}.first
    end

    def next
      current_index = @commits.index(current_head)
      next_index = current_index - 1
      next_ref = @commits.fetch(next_index).first
      GitNav::GitWrapper.checkout(next_ref)
    end

    def prev
      current_index = @commits.index(current_head)
      prev_index = current_index + 1
      prev_ref = @commits.fetch(prev_index).first
      GitNav::GitWrapper.checkout(prev_ref)
    end

    private

    def is_git_repo?(repo)
      File.exist?(File.join(repo, ".git"))
    end
  end
end

