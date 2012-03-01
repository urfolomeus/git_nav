require 'spec_helper'

describe GitNav::GitNavigator do
  let(:reflog) {<<-REFLOG
      5d6e7f8 HEAD@{0}: commit: Test commit
      1a2b3c4 HEAD@{1}: commit (initial): Initial commit
    REFLOG
  }

  before :each do
    File.stub(:exist?).and_return(true)
    Dir.stub(:chdir)
    GitNav::GitWrapper.stub(:reflog).and_return(reflog)
  end

  describe "initialization" do
    context "if dir is valid git repo" do
      it "doesn't change directory if no directory given" do
        Dir.stub(:pwd).and_return("current_dir")
        Dir.should_receive(:chdir).with("current_dir")
        GitNav::GitNavigator.new
      end

      it "changes directory if directory given" do
        Dir.should_receive(:chdir).with("test_dir")
        GitNav::GitNavigator.new "test_dir"
      end
    end

    context "if dir is not valid git repo" do
      it "raises exception" do
        File.stub(:exist?).and_return(false)
        expect {
          GitNav::GitNavigator.new "not_git"
        }.to raise_error(GitError, "Not a git repo")
      end
    end
  end

  describe "getting a particular commit" do
    let(:git_nav) { GitNav::GitNavigator.new }

    it "gets a list of commits" do
      expected = [
        ["5d6e7f8", "Test commit"],
        ["1a2b3c4", "Initial commit"]
      ]
      git_nav.commits.should == expected
    end

    it "gets the current head when the HEAD is attached" do
      GitNav::GitWrapper.stub(:head).and_return("ref: refs/heads/master")
      git_nav.current_head.should == ["5d6e7f8", "Test commit"]
    end

    it "gets the current commit when the HEAD is detached" do
      GitNav::GitWrapper.stub(:head).and_return("1a2b3c47f8abc7de6f5gh3y")
      git_nav.current_head.should == ["1a2b3c4", "Initial commit"]
    end

    it "gets the next commit" do
      GitNav::GitWrapper.stub(:head).and_return("1a2b3c47f8abc7de6f5gh3y")
      GitNav::GitWrapper.should_receive(:checkout).with("5d6e7f8")
      git_nav.next
    end

    it "gets the prev commit" do
      GitNav::GitWrapper.stub(:head).and_return("5d6e7f81ah5ys6")
      GitNav::GitWrapper.should_receive(:checkout).with("HEAD~1")
      git_nav.prev
    end

    it "outputs a nice log" do
      git_nav.log.should == "* 5d6e7f8 Test commit\n  1a2b3c4 Initial commit"
    end
  end
end

