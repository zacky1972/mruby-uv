#!mruby

t = UV::Timer.new
UV::Signal.new.start(UV::Signal::SIGPIPE) do
  puts "connection closed"
  t.stop
end

s = UV::TCP.new
s.bind(UV::ip4_addr('127.0.0.1', 8888))
s.listen(5) {|x|
  return if x != 0
  c = s.accept
  puts "connected"
  c.write "helloworld\r\n"
  t.start(1000, 1000) {|x|
    puts "helloworld\n"
    begin
      c.write "helloworld\r\n"
    rescue RuntimeError
		puts "foo"
      c.close
      c = nil
      t.stop
      t = nil
    end
  }
}

UV::run()
