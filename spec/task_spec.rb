describe Task do
  subject(:task) do
    described_class.new(result_file_path: result_file_path, data_file_path: data_file_path)
  end

  let(:result_file_path) { 'spec/fixtures/result.json' }
  let(:data_file_path) { 'spec/fixtures/data.txt' }
  let(:expected_result) do
    '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
  end
  let(:exepcted_data_from_file) { File.read(result_file_path) }

  before do
    allow(ProgressBar).to receive(:create).and_return(double(increment: true))
  end

  after do
    File.delete(result_file_path) if File.exist?(result_file_path)
  end

  describe "#work" do
    it "tests file" do
      task.work
      expect(exepcted_data_from_file).to eq(expected_result)
    end

    describe "performnce test" do
      context "when 100k rows" do
        let(:data_file_path) { 'spec/fixtures/data_100k.txt' }
        let(:task_work_time) { Benchmark.measure { task.work }.real }
        let(:task_memory_usage) do
          usage_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024
          task.work
          usage_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024

          usage_after - usage_before
        end

        it 'executes faster than 0.6 seconds' do
          expect(task_work_time).to be < 0.6
        end

        it 'uses less then 6 megabyte' do
          expect(task_memory_usage).to be < 6
        end
      end
    end
  end
end
