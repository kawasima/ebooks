#!/usr/bin/ruby

if ARGV.size < 2
  puts "#{$0} [width] [height] < [input_pdf] > [output_pdf]"
  exit
end

width  = ARGV[0].to_f
height = ARGV[1].to_f

xref_offset  = 0
page_offsets = []
total_len    = 0
crop_first   = true

STDIN.each{|line|
  line.sub!(/CropBox \[ ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.]+) \]/) {
    if crop_first 
      crop_first = false
      $&
    else
      "CropBox[ #{width} #{height} #{$3.to_f - width} #{$4.to_f - height} ]"
    end
  }

  if /^(\d+) (\d+) obj$/ =~ line
    page_offsets << total_len
  elsif /^\d{10} (\d{5}) n $/ =~ line
    line = sprintf("%010d #{$1} n " , page_offsets.shift)
  elsif /^xref$/ =~ line
    xref_offset = total_len
  elsif /^startxref$/ =~ line
    puts "startxref"
    puts xref_offset
    puts "%%EOF"
    break
  end
  puts line
  total_len += line.size
}

