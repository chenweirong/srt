require File.expand_path('../srt_converter', __FILE__)
# Main Program GIT
puts '请选择你要对时间轴进行的操作(加/减):(plus/minus)'
order = gets
order = order.rstrip
puts '请输入需要调整的秒数(建议<3600):'
second = gets
puts '请输入需调整的毫秒数(建议<3600000):'
microsecond = gets
puts '请输入字幕文件输入路径:'
filepath_in = gets
puts '请输入字幕文件输出路径::'
filepath_out = gets
ch = SrtConverter.new(filepath_in,filepath_out)
# ch.srt_in_path  = '/Users/chenweirong/Desktop/Rio.srt'
# puts ch.srt_in_path
# ch.srt_in_path  = filepath_in.rstrip
# ch.srt_out_path = filepath_out.rstrip
puts ch.srt_in_path
ch.convert_time(order,second,microsecond)