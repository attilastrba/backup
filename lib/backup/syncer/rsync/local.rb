module Backup
  module Syncer
    module RSync
      class Local < Base
        attr_accessor :link_dest
        attr_accessor :keep_snapshot

        def perform!
          log!(:started)

          create_dest_path!
          run("#{rsync_command}#{link_dest_option} #{paths_to_push} '#{dest_path}'")

          remove_old_snapshot if link_dest & !keep_snapshot.nil?
          log!(:finished)
        end

        private

        def remove_old_snapshot
          count = 0
          files = Dir.glob("#{File.expand_path(@path)}/../*").sort.reverse
          files.each do |process_dir|
         #   next if File.file?(process_dir)
            count = count + 1
            next if count <= keep_snapshot

            log!("Removing old backup dir #{process_dir}")
            FileUtils.rm_rf(process_dir)
          end
        end

        def link_dest_option
          link_dest ? link_dest_param : ""
        end


        def link_dest_param
          #always take the newest folder as the source of the link destination
          link_folder = Dir.glob("#{@dest_path}/*").sort.reverse[0]
          link_folder.nil? ?  "" : " --link-dest=#{link_folder}"
        end

        # Expand path, since this is local and shell-quoted.
        def dest_path
          @dest_path ||= File.expand_path(path)
        end

        def create_dest_path!
          @path = "#{@path}/#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}"  if link_dest
          FileUtils.mkdir_p dest_path
        end
      end
    end
  end
end
