#!/usr/bin/ruby -I../src
$LOAD_PATH.unshift "../src"
require 'bdbxml'
require 'find'

Find::find('env') do |f|
   File::unlink(f) if FileTest::file? f
end

env = BDB::Env.new("env", BDB::CREATE | BDB::INIT_TRANSACTION)
doc = env.open_xml("toto", "a")
bdb = env.open_db(BDB::Btree, "tutu", nil, "a")
2.times do |i|
   doc.push("<bk><ttl id='#{i}'>title nb #{i}</ttl></bk>")
   bdb[i] = "bdb#{i}"
end
env.begin(doc, bdb) do |txn, doc1, bdb1|
   2.times do |i|
      bdb1[i+2] = "bdb#{i+2}"
      doc1.push("<bk><ttl id='#{i+2}'>title nb #{i+2}</ttl></bk>")
   end
   puts "========================================="
   doc1.each("//ttl[@id < 12]", BDB::XML::Context::Values) {|x| p x }
   bdb1.each {|k,v| p "#{k} -- #{v}" }
end
puts "========================================="
doc.each("//ttl[@id < 12]") {|x| p x }
bdb.each {|k,v| p "#{k} -- #{v}" }
