require 'time'

module MCP
  module Tools
    class Timer
      def initialize
        # タイマーセッション情報をインスタンス変数として管理
        @timer_sessions = {}
      end

      def tools
        [timer_start, timer_stop, timer_list]
      end

      private

      def timer_start
        {
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
              @timer_sessions[task_name] = {
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
        }
      end

      def timer_stop
        {
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
            session = @timer_sessions[task_name]

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
                @timer_sessions.delete(task_name)

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
        }
      end

      def timer_list
        {
          name: 'timer_list',
          description: 'List all currently running time tracking tasks',
          input_schema: {
            type: 'object',
            properties: {}
          },
          handler: proc do |_args|
            if @timer_sessions.empty?
              {
                status: 'info',
                message: 'No active tasks'
              }
            else
              current_time = Time.now
              active_tasks = @timer_sessions.map do |task_name, session|
                start_time = session[:start_time]

                # Calculate elapsed time
                elapsed_seconds = current_time - start_time
                hours = (elapsed_seconds / 3600).to_i
                minutes = ((elapsed_seconds % 3600) / 60).to_i
                seconds = (elapsed_seconds % 60).to_i
                formatted_elapsed = format('%02d:%02d:%02d', hours, minutes, seconds)

                {
                  task: task_name,
                  start_time: start_time.iso8601,
                  elapsed_time: formatted_elapsed,
                  elapsed_seconds: elapsed_seconds.to_i,
                  timezone: session[:timezone]
                }
              end

              {
                status: 'success',
                active_task_count: active_tasks.size,
                tasks: active_tasks
              }
            end
          end
        }
      end
    end
  end
end
