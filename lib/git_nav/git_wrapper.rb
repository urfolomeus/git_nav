module GitNav
  class GitWrapper
    def self.reflog
      `git reflog`
    end

    def self.head
      File.read(File.join(Dir.pwd, ".git", "HEAD")).chomp
    end

    def self.checkout(ref)
      `nohup git checkout #{ref}`
    end
  end
end

