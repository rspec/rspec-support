require 'rspec/support/reentrant_mutex'
require 'thread_order'

RSpec.describe RSpec::Support::Mutex do
  it "allows ::Mutex to be mocked" do
    expect(Mutex).to receive(:new)
    ::Mutex.new
  end
end

# There are no assertions specifically
# They pass if they don't deadlock
RSpec.describe RSpec::Support::ReentrantMutex do
  let!(:mutex) { described_class.new }
  let!(:order) { ThreadOrder.new }
  after { order.apocalypse! }

  it 'can repeatedly synchronize within the same thread' do
    mutex.synchronize { mutex.synchronize { } }
  end

  it 'locks other threads out while in the synchronize block' do
    order.declare(:before) { mutex.synchronize { } }
    order.declare(:within) { mutex.synchronize { } }
    order.declare(:after)  { mutex.synchronize { } }

    order.pass_to :before, :resume_on => :exit
    mutex.synchronize { order.pass_to :within, :resume_on => :sleep }
    order.pass_to :after, :resume_on => :exit
  end

  it 'resumes the next thread once all its synchronize blocks have completed' do
    order.declare(:thread) { mutex.synchronize { } }
    mutex.synchronize { order.pass_to :thread, :resume_on => :sleep }
    order.join_all
  end

  if RUBY_VERSION >= '3.0'
    it 'waits when trying to lock from another Fiber' do
      mutex.synchronize do
        ready = false
        f = Fiber.new do
          expect {
            ready = true
            mutex.send(:enter)
            raise 'should reach here: mutex is already locked on different Fiber'
          }.to raise_error(Exception, 'waited correctly')
        end

        main_thread = Thread.current

        t = Thread.new do
          Thread.pass until ready and main_thread.stop?
          main_thread.raise Exception, 'waited correctly'
        end
        f.resume
        t.join
      end
    end
  end
end
