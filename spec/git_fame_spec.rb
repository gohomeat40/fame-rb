describe GitFame::Base do
  let(:subject) { GitFame::Base.new({repository: @repository}) }
  describe "#authors" do
    it "should have a list of authors" do
      subject.should have(3).authors
    end

    describe "author" do
      let(:author) { subject.authors.last }
      it "should have a bunch of commits" do
        author.raw_commits.should eq(23)
      end

      it "should respond to name" do
        author.name.should eq("Linus Oleander")
      end

      it "should have a number of locs" do
        author.raw_loc.should eq(136)
      end

      it "should have a number of files" do
        author.raw_files.should eq(7)
      end

      it "should have a distribution" do
        author.distribution.should eq("12.6 / 32.9 / 43.8")
      end
    end
    describe "format" do
      let(:author) do 
        GitFame::Author.new({
          raw_commits: 12345, 
          raw_files: 6789, 
          raw_loc: 1234
        })
      end

      it "should format #commits" do
        author.commits.should eq("12,345")
      end

      it "should format #files" do
        author.files.should eq("6,789")
      end

      it "should format #loc" do
        author.loc.should eq("1,234")
      end
    end
  end

  describe "total" do
    it "should respond to #loc, #commits and #files" do
      subject.files.should eq(16)
      subject.commits.should eq(70)
      subject.loc.should eq(1082)
    end
  end

  describe "sort" do
    it "should be able to sort #authors by name" do
      authors = GitFame::Base.new({
        repository: @repository, 
        sort: "name"
      }).authors
      authors.map(&:name).
        should eq(["7rans", "Linus Oleander", "Magnus Holm"])
    end

    it "should be able to sort #authors by commits" do
      authors = GitFame::Base.new({
        repository: @repository, 
        sort: "commits"
      }).authors
      authors.map(&:name).
        should eq(["Magnus Holm", "Linus Oleander", "7rans"])
    end

    it "should be able to sort #authors by files" do
      authors = GitFame::Base.new({
        repository: @repository, 
        sort: "files"
      }).authors
      authors.map(&:name).
        should eq(["7rans", "Linus Oleander", "Magnus Holm"])
    end
  end

  describe "#command_line_arguments" do
    let(:subject) do 
      GitFame::Base.new({
        repository: @repository, 
        exclude: "lib", 
        bytype: true
      }) 
    end

    it "should exclude the lib folder" do
      subject.file_list.include?("lib/gash.rb").should be_false
    end

    let(:author) { subject.authors.first }
    it "should break out counts by file type" do
      author.file_type_counts["rdoc"].should eq(23)
    end

    it "should output zero for file types the author hasn't touched" do
      author.file_type_counts["derp"].should eq(0)
    end
  end

  describe "#pretty_print" do
    it "should print" do
      lambda {
        2.times { subject.pretty_puts }
      }.should_not raise_error
    end
  end

  describe "#csv_print" do
    it "should print" do
      lambda {
        subject.csv_puts
      }.should_not raise_error
    end

    it "should be equal to" do
      subject.csv.should eq("name,loc,commits,files,distribution\n" \
                            "Magnus Holm,586,41,4,54.2 / 58.6 / 25.0\n" \
                            "7rans,360,6,10,33.3 / 8.6 / 62.5\n" \
                            "Linus Oleander,136,23,7,12.6 / 32.9 / 43.8\n")
    end
  end

  describe ".git_repository?" do
    it "should know if a folder is a git repository [absolute path]" do
      GitFame::Base.git_repository?(@repository).should eq(true)
    end

    it "should know if a folder exists or not [absolute path]" do
      GitFame::Base.git_repository?("/f67c2bcbfcfa30fccb36f72dca22a817").
        should eq(false)
    end

    it "should know if a folder is a git repository [relative path]" do
      GitFame::Base.git_repository?("spec/fixtures/gash").should eq(true)
    end

    it "should know if a folder exists or not [relative path]" do
      GitFame::Base.git_repository?("f67c2bcbfcfa30fccb36f72dca22a817").
        should eq(false)
    end
  end

  describe "branches" do
    it "should handle existing branches" do
      authors = GitFame::Base.new({
        repository: @repository, 
        branch: "0.1.0"
      }).authors

      authors.count.should eq(1)
      authors.first.name.should eq("Magnus Holm")
    end

    it "should raise an error if branch doesn't exist" do
      expect {
        GitFame::Base.new({
          repository: @repository, 
          branch: "f67c2bcbfcfa30fccb36f72dca22a817"
        }).authors
      }.to raise_error(GitFame::BranchNotFound)
    end
  end
end