require_relative '../server'
require 'time'

# Timer server for time tracking
server = MCP::Server.new

# ユーザーのタイムトラッキングセッションを保存するハッシュ
# key: 作業名, value: {start_time: Time, timezone: String}
timer_sessions = {}

# タイムトラッキングを開始するツール
server.register_tool(
  name: 'timer_start',
  description: 'Start tracking time for a task',
  input_schema: {
    type: 'object',
    properties: {
      task_name: {
        type: 'string',
        description: 'Name of the task to track (defaults to "untitled")'
      },
      timezone: {
        type: 'string',
        description: 'Timezone in IANA format (e.g., "Asia/Tokyo", "UTC", "America/New_York")'
      }
    }
  },
  handler: proc do |args|
    task_name = args[:task_name] || 'untitled'
    timezone = args[:timezone] || 'system'

    begin
      current_time = if timezone != 'system'
                       Time.now.getlocal(TZInfo::Timezone.get(timezone).current_period.offset.utc_total_offset)
                     else
                       Time.now
                     end

      # 既存のセッションがあれば上書き
      timer_sessions[task_name] = {
        start_time: current_time,
        timezone: timezone
      }

      {
        status: 'started',
        task: task_name,
        start_time: current_time.iso8601,
        timezone: timezone
      }
    rescue StandardError => e
      { error: "Failed to start timer: #{e.message}" }
    end
  end
)

# タイムトラッキングを終了するツール
server.register_tool(
  name: 'timer_stop',
  description: 'Stop tracking time for a task and show elapsed time',
  input_schema: {
    type: 'object',
    properties: {
      task_name: {
        type: 'string',
        description: 'Name of the task to stop tracking'
      }
    },
    required: ['task_name']
  },
  handler: proc do |args|
    task_name = args[:task_name]
    session = timer_sessions[task_name]

    if session.nil?
      { error: "No active timer found for task '#{task_name}'" }
    else
      begin
        timezone = session[:timezone]
        start_time = session[:start_time]

        current_time = if timezone != 'system'
                         Time.now.getlocal(TZInfo::Timezone.get(timezone).current_period.offset.utc_total_offset)
                       else
                         Time.now
                       end

        # 経過時間を秒単位で計算
        elapsed_seconds = current_time - start_time

        # 時間：分：秒 の形式に変換
        hours = (elapsed_seconds / 3600).to_i
        minutes = ((elapsed_seconds % 3600) / 60).to_i
        seconds = (elapsed_seconds % 60).to_i
        formatted_elapsed = format('%02d:%02d:%02d', hours, minutes, seconds)

        # セッションを削除
        timer_sessions.delete(task_name)

        {
          status: 'stopped',
          task: task_name,
          start_time: start_time.iso8601,
          end_time: current_time.iso8601,
          elapsed_time: formatted_elapsed,
          elapsed_seconds: elapsed_seconds
        }
      rescue StandardError => e
        { error: "Failed to stop timer: #{e.message}" }
      end
    end
  end
)

# サーバー実行
server.run
