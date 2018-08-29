require "redis"

redis = Redis.new(:url => "redis://127.0.0.1:6379/1")

redis.rpush("test:x1", 1)
redis.rpush("test:x1", 2)

redis.rpush("test:x2", 3)

r = redis.brpop("test:x1", "test:x2", 0)
count = 0
while r
  count += 1
  puts "输出结果, #{count}"
  p r
  r = redis.brpop("test:x1", "test:x2", 0)
end

