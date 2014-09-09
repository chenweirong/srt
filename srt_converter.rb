class SrtConverter
  attr_accessor :srt_in_path, :srt_out_path
  def initialize(filepath_in,filepath_out)
    @srt_in_path  = filepath_in
    @srt_out_path = filepath_out
  end
  # 时间调整方法
  # plus_or_minus－表调整方式，可选为：加'plus'、减'minus'；second－调整秒数；microsecond－调整微秒数
  def convert_time(plus_or_minus,second,microsecond)
    second_and_microsecond_arr = analyse_plus_or_minus(plus_or_minus,second,microsecond)
    if File::exists?(@srt_in_path)
      srt_arr_in = IO.readlines(@srt_in_path)
      srt_arr_out = serch_and_convert_time(second_and_microsecond_arr[0],second_and_microsecond_arr[1],srt_arr_in)
      file_srt_save = File.new(@srt_out_path, 'w')
      file_srt_save.puts(srt_arr_out)
      puts 'complete!'
    else
      puts 'error!'
    end
  end

  private
  def analyse_plus_or_minus(plus_or_minus,second,microsecond)
    second_and_microsecond_arr = []
    #chang_second－需调整的秒数总和,#chang_microsecond－需调整的微妙数总和。
    tmp_microsecond   = microsecond.to_i.abs.divmod(1000)
    second_and_microsecond_arr[0] = second.to_i.abs + tmp_microsecond[0]
    second_and_microsecond_arr[1] = tmp_microsecond[1]
    if plus_or_minus == 'minus'
      second_and_microsecond_arr[0] *= -1
      second_and_microsecond_arr[1] *= -1
    end
    second_and_microsecond_arr
  end
  # 处理时间，并将处理后的时间保存到数组，以便保存。
  def serch_and_convert_time(chang_second,chang_microsecond,srt_arr_in)
    srt_arr =[]
    srt_arr_in.each { |line|
      # 用正则表达式找出代表时间的字符串，如果是时间字符则进行处理后再添加到数组，否则直接添加到数组
      time_mth = /([\d]{2}:){2}[\d]{2},[\d]{3}[\s]-->[\s]([\d]{2}:){2}[\d]{2},[\d]{3}/.match(line)
      # 对表示时间的字符串进行整理，这里的方法是将时间转换为总的秒数和总的微秒数来进行时间的加减调整
      if time_mth
        line = alter_time(analyse_time(0, time_mth, chang_second,chang_microsecond)) + ' ' +
            '-->' + ' ' + alter_time(analyse_time(17, time_mth, chang_second,chang_microsecond))
        srt_arr << line
      else
        srt_arr << line
      end
    }
    srt_arr
  end

  def alter_time(total_time)
    time_array=[]
    tmp_hour = total_time[0].divmod(3600)
    time_array[0] = tmp_hour[0].to_i
    tmp_minute = tmp_hour[1].divmod(60)
    time_array[1] = tmp_minute[0].to_i
    time_array[2] = tmp_minute[1].to_i
    time_array[3] = total_time[1].to_i
    '%02d:%02d:%02d,%03d'%[time_array[0],time_array[1],time_array[2],time_array[3]]
  end
  # 对时间进行处理，返回标准srt的时间轴格式。
  # start_num－从哪开始截取时间；regex_array－正在表达式的列表；
  # chang_second－要调整的秒的总和；chang_microsecond－要调整的微秒的总和
  def analyse_time(start_num,regex_array,chang_second,chang_microsecond)
    hour = regex_array.string[start_num,2].to_i
    minute = regex_array.string[start_num+3,2].to_i
    second = regex_array.string[start_num+6,2].to_i
    microsecond = regex_array.string[start_num+9,3].to_i
    compute_time(hour,minute,second,microsecond,chang_second,chang_microsecond)
  end

  def compute_time(hour,minute,second,microsecond,chang_second,chang_microsecond)
    total_microsecond = (microsecond + chang_microsecond)
    # plus_or_minus_mark－加或减的符号标记
    (total_microsecond == 0) ? plus_or_minus_mark = 1 : plus_or_minus_mark = total_microsecond/(total_microsecond.abs)
    compute_second_and_microsecond(plus_or_minus_mark,total_microsecond,chang_second,hour,minute,second)
  end

  def compute_second_and_microsecond(plus_or_minus_mark,total_microsecond,chang_second,hour,minute,second)
    total_change_time = []
    tmp_microsecond = total_microsecond.abs.divmod(1000)
    total_change_time[0] = hour*3600 + minute*60 + second + chang_second + tmp_microsecond[0]*plus_or_minus_mark
    total_change_time[1] = tmp_microsecond[1]*plus_or_minus_mark
    if total_change_time[1] < 0
      total_change_time[0]-=1
      total_change_time[1]+=1000
    end
    raise '调整时间范围过大' if total_change_time[0] < 0
    total_change_time
  end

end