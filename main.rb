require 'json'
require_relative 'data_layout'

class Lib
  def initialize(store = nil)
    @store = store || {}
    @params = Layout
    Layout.keys.each { |k| @store[k] = [] } unless store
  end

  def add(type, *args)
    ret = Hash[@params[type].zip args]
    @store[type].push(ret)
    ret
  end

  def [](type, **kwargs)
    @store[type].find { |o| kwargs <= o }
  end

  def to_file(path)
    File.open(path, 'w') { |fp| fp.write(@store.to_json) }
  end

  def self.from_file(name)
    new JSON.parse(File.read(name), symbolize_names: true)
  end

  def who_often_take(the_book)
    t = if the_book.is_a? Hash
          @store[:Order].select { |o| o[:Book] == the_book }
        else
          @store[:Order].select { |o| o[:Book][:title] == the_book }
        end
    q = t.group_by { |o| o[:Reader] }
    q.max_by { |_, v| v.count }.first
  end

  def most_popular
    t = @store[:Order].group_by { |o| o[:Book] }
    t.max_by { |_, v| v.count }.first
  end

  def how_many_ordered
    p = @store[:Order].group_by { |o| o[:Book] }
    top = p.sort_by { |_, v| -v.count }[0..2]
    top.map { |_, p2| p2 }.flatten.group_by { |o| o[:Reader] }.count
  end

end



if $PROGRAM_NAME == __FILE__
  lib = Lib.new
  a = lib.add(:Author, 'asd', 'dsa')
  b1 = lib.add(:Book, 'b1', a)
  b2 = lib.add(:Book, 'b2', a)
  b3 = lib.add(:Book, 'b3', a)
  b4 = lib.add(:Book, 'b4', a)
  b5 = lib.add(:Book, 'b5', a)
  r1 = lib.add(:Reader, '1', '1', '1', '1', '1')
  r2 = lib.add(:Reader, '2', '2', '2', '2', '3')
  r3 = lib.add(:Reader, '3', '3', '3', '3', '3')
  r4 = lib.add(:Reader, '4', '4', '4', '4', '4')
  [
    [b1, r1],
    [b1, r1],
    [b2, r2],
    [b2, r2],
    [b3, r3],
    [b3, r3],
    [b4, r4],
    [b4, r4],
    [b5, r4],
    [b5, r1],
    [b5, r2],
    [b5, r3]
  ].map { |b, r| lib.add(:Order, b, r) }

  [b1, b2, b3, b4].zip [r1, r2, r3, r4].map do |b, r|
    unless lib.who_often_take(b) == r
      raise 'nth reader takes nth book the most'
    end
  end

  unless lib.how_many_ordered == 4
    raise 'book b5 was taken the most and by all reader'
  end

  unless lib.most_popular == b5
    raise 'book b5 is the most popular'
  end

end
