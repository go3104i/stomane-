class TestBatch
    def self.execute
      controller = StocksController.new
      controller.price_geter_all
    end
  end
  TestBatch.execute